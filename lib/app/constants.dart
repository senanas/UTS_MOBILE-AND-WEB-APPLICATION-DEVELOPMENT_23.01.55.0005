// Konstanta aplikasi ChronoStore.

class AppConstants {
  // Nama aplikasi
  static const String appName = 'ChronoStore';

  // Label navigasi
  static const String navDashboard = 'Dashboard';
  static const String navWatchList = 'Data Jam';
  static const String navReminder = 'Pengingat';
  static const String navRiwayat = 'Riwayat';

  // Label tombol
  static const String btnLogin = 'Masuk';
  static const String btnRegister = 'Daftar';
  static const String btnSave = 'Simpan';
  static const String btnCancel = 'Batal';
  static const String btnAddWatch = 'Tambah Jam Tangan';
  static const String btnRecordService = 'Catat Servis';
  static const String btnOrder = 'Pesan';
  static const String btnLogout = 'Keluar';

  // Label role
  static const String roleAdmin = 'Admin';
  static const String roleCustomer = 'Pelanggan';

  // Bootstrap admin: email ini SELALU diperlakukan sebagai Admin, walaupun
  // dokumen users/{uid} lama di Firestore masih berisi 'pelanggan'.
  // Tambahkan email lain di sini bila dosen/penguji memakai akun admin lain.
  static const Set<String> emailAdmin = {
    'admin@chronostore.com',
  };

  // Label empty state
  static const String emptyWatches = 'Belum ada data jam tangan';
  static const String emptyServices = 'Belum ada riwayat servis';
  static const String emptyReminders = 'Tidak ada pengingat aktif';
  static const String emptyTransactions = 'Belum ada transaksi';

  // Pengingat
  static const int reminderWarningDays = 7;
}

/// Named routes.
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String watchList = '/watches';
  static const String watchForm = '/watches/form';
  static const String watchDetail = '/watches/detail';
  static const String serviceHistory = '/services';
  static const String reminder = '/reminder';
  static const String catalog = '/catalog';
  static const String transaction = '/transactions';
  static const String transactionForm = '/transactions/form';
  static const String profile = '/profile';
}
