import 'dart:async';

import '../data/data_chronostore.dart';
import '../models/transaction.dart';
import '../models/user_account.dart';
import '../models/watch.dart';
import '../utils/id_generator.dart';
import 'layanan_chronostore.dart';

/// Implementasi in-memory dari [LayananChronoStore].
///
/// Dipakai untuk widget/unit test supaya test tidak menyentuh Firebase asli
/// (lihat tabel "Masalah umum" modul Minggu 10). Perilaku bisnisnya dibuat
/// sama persis dengan [LayananFirestore]: auto-seed, stream, cek bentrok,
/// pengurangan stok, dan isolasi transaksi per pengguna.
class LayananMemori implements LayananChronoStore {
  final Map<String, UserAccount> _profil = {};
  final List<Watch> _jam = [];
  final List<Transaction> _transaksi = [];

  final _jamController = StreamController<List<Watch>>.broadcast();
  final _txController = StreamController<List<Transaction>>.broadcast();
  final _profilController =
      StreamController<Map<String, UserAccount>>.broadcast();

  // ---------------------------------------------------------------- users ---

  @override
  Future<void> simpanProfilSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
    UserRole? peran,
  }) async {
    if (_profil.containsKey(uid)) return;
    final namaBersih = (namaLengkap ?? '').trim();
    _profil[uid] = UserAccount(
      id: uid,
      name: namaBersih.isNotEmpty ? namaBersih : email.split('@').first,
      email: email,
      password: '',
      role: peran ?? UserRole.customer,
    );
    _emitProfil();
  }

  @override
  Future<UserRole?> bacaPeran(String uid) async => _profil[uid]?.role;

  @override
  Future<void> perbaruiPeran(String uid, UserRole peran) async {
    final akun = _profil[uid];
    _profil[uid] = (akun ??
            UserAccount(
              id: uid,
              name: 'Pengguna',
              email: '',
              password: '',
              role: UserRole.customer,
            ))
        .copyWith(role: peran);
    _emitProfil();
  }

  @override
  Stream<UserAccount?> streamProfil(String uid) => _denganNilaiAwal(
        _profil[uid],
        _profilController.stream.map((map) => map[uid]),
      );

  // -------------------------------------------------------------- watches ---

  @override
  Future<void> isiJamAwalJikaKosong() async {
    if (_jam.isNotEmpty) return;
    _jam.addAll(daftarJamAwal);
    _emitJam();
  }

  @override
  Stream<List<Watch>> streamDaftarJam() => _denganNilaiAwal(
        List<Watch>.unmodifiable(_jam),
        _jamController.stream,
      );

  @override
  Future<Watch> tambahJam(Watch watch) async {
    final baru = watch.copyWith(
      id: IdGenerator.generate('w'),
      createdAt: DateTime.now(),
    );
    _jam.add(baru);
    _emitJam();
    return baru;
  }

  @override
  Future<void> ubahJam(Watch watch) async {
    final idx = _jam.indexWhere((w) => w.id == watch.id);
    if (idx == -1) return;
    _jam[idx] = watch;
    _emitJam();
  }

  @override
  Future<void> hapusJam(String id) async {
    _jam.removeWhere((w) => w.id == id);
    _emitJam();
  }

  // ---------------------------------------------------------- transactions ---

  @override
  Future<void> tambahTransaksi({
    required String uid,
    required String namaPelanggan,
    required String watchId,
    required String watchName,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required int ongkir,
    String emailPelanggan = '',
    String teleponPelanggan = '',
    String alamatPengiriman = '',
    String kota = '',
    String kodePos = '',
    String catatan = '',
  }) async {
    final tanggal = formatTanggal(DateTime.now());
    final namaJam = watchName.isNotEmpty
        ? watchName
        : _jam
            .firstWhere(
              (w) => w.id == watchId,
              orElse: () => Watch(
                id: watchId,
                name: '',
                brand: '',
                model: '',
                movementType: WatchType.quartz,
                price: 0,
                stock: 0,
                serialNumber: '',
                createdAt: DateTime.now(),
              ),
            )
            .name;

    final bentrok = _transaksi.any((t) =>
        t.userId == uid &&
        t.watchId == watchId &&
        formatTanggal(t.transactionDate) == tanggal &&
        t.status != TransactionStatus.cancelled);
    if (bentrok) {
      throw const TransaksiBentrokException(
        'Jam tangan ini sudah Anda pesan hari ini.',
      );
    }

    final idx = _jam.indexWhere((w) => w.id == watchId);
    if (idx == -1) {
      throw const StokTidakCukupException('Jam tangan tidak ditemukan.');
    }
    if (_jam[idx].stock < quantity) {
      throw StokTidakCukupException('Stok tinggal ${_jam[idx].stock} unit.');
    }

    final sekarang = DateTime.now();
    _transaksi.add(Transaction(
      id: IdGenerator.generate('t'),
      watchId: watchId,
      watchName: namaJam,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      transactionDate: sekarang,
      customerName: namaPelanggan,
      customerEmail: emailPelanggan,
      customerPhone: teleponPelanggan,
      shippingAddress: alamatPengiriman,
      shippingCity: kota,
      postalCode: kodePos,
      notes: catatan,
      shippingCost: ongkir,
      userId: uid,
      status: TransactionStatus.completed,
      createdAt: sekarang,
    ));
    _jam[idx] = _jam[idx].copyWith(stock: _jam[idx].stock - quantity);
    _emitTx();
    _emitJam();
  }

  @override
  Stream<List<Transaction>> streamTransaksiSaya(String uid) => _denganNilaiAwal(
        _urutkan(_transaksi.where((t) => t.userId == uid).toList()),
        _txController.stream.map(
          (list) => _urutkan(list.where((t) => t.userId == uid).toList()),
        ),
      );

  @override
  Stream<List<Transaction>> streamSemuaTransaksi() => _denganNilaiAwal(
        _urutkan(List<Transaction>.from(_transaksi)),
        _txController.stream,
      );

  @override
  Future<void> ubahStatusTransaksi(String id, TransactionStatus status) async {
    final idx = _transaksi.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    _transaksi[idx] = _transaksi[idx].copyWith(status: status);
    _emitTx();
  }

  // -------------------------------------------------------------- helper ---

  /// Buat stream yang langsung mengirim keadaan saat ini, lalu meneruskan
  /// setiap perubahan. Berlangganan ke controller dilakukan di `onListen`
  /// (sinkron saat listener pertama datang) supaya tidak ada event yang hilang.
  Stream<T> _denganNilaiAwal<T>(T awal, Stream<T> sumber) {
    late StreamSubscription<T> langganan;
    late final StreamController<T> kontroler;

    kontroler = StreamController<T>(
      onListen: () {
        langganan = sumber.listen(
          (event) {
            if (!kontroler.isClosed) kontroler.add(event);
          },
          onError: (Object error) {
            if (!kontroler.isClosed) kontroler.addError(error);
          },
        );
        if (!kontroler.isClosed) kontroler.add(awal);
      },
      onCancel: () {
        langganan.cancel();
      },
    );
    return kontroler.stream;
  }

  List<Transaction> _urutkan(List<Transaction> list) {
    list.sort((a, b) => (b.createdAt ?? b.transactionDate)
        .compareTo(a.createdAt ?? a.transactionDate));
    return list;
  }

  void _emitJam() {
    if (!_jamController.isClosed) {
      _jamController.add(List<Watch>.unmodifiable(_jam));
    }
  }

  void _emitTx() {
    if (!_txController.isClosed) {
      _txController.add(List<Transaction>.unmodifiable(_transaksi));
    }
  }

  void _emitProfil() {
    if (!_profilController.isClosed) {
      _profilController.add(Map<String, UserAccount>.from(_profil));
    }
  }

  /// Panggil di `tearDown` test.
  void dispose() {
    _jamController.close();
    _txController.close();
    _profilController.close();
  }
}
