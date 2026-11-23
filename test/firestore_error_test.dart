import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jam_tangan/services/firestore_error.dart';

void main() {
  group('FirestoreError.pesan', () {
    test('permission-denied memberi saran publish Rules', () {
      final pesan = FirestoreError.pesan(
        FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Missing or insufficient permissions.',
        ),
      );
      expect(pesan, contains('permission-denied'));
      expect(pesan, contains('Publish'));
      expect(pesan, contains('request.auth != null'));
    });

    test('failed-precondition memberi saran index', () {
      final pesan = FirestoreError.pesan(
        FirebaseException(plugin: 'cloud_firestore', code: 'failed-precondition'),
      );
      expect(pesan, contains('index'));
    });

    test('error non-Firebase tetap ditampilkan', () {
      expect(FirestoreError.pesan('ups'), contains('ups'));
    });
  });
}
