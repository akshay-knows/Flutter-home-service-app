import 'dart:math';

class TrackingNumberService {
  static final Random _random = Random.secure();

  static String generate() {
    final number = 100000 + _random.nextInt(900000);
    return 'OT-$number';
  }
}
