/// Generate ID unik untuk entitas lokal.
class IdGenerator {
  static int _counter = 0;

  static String generate(String prefix) {
    _counter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_${timestamp}_$_counter';
  }

  static String generateSerialNumber() {
    _counter++;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'CS${timestamp.toString().substring(6)}$_counter';
  }
}
