import 'dart:math';

class Idempotency {
  static final Set<String> _active = <String>{};

  static String create(String action, String subject) =>
      '$action:$subject:${DateTime.now().millisecondsSinceEpoch}:${Random().nextInt(1 << 20)}';

  static bool begin(String key) => _active.add(key);

  static void end(String key) => _active.remove(key);
}
