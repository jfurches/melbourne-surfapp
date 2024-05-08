import 'dart:math';

import 'package:surfapp/data/conditions.dart';
import 'package:test/test.dart';

void main() {
  group('Test wind', () {
    test('Test speed', () {
      // Check that it correctly stores our value
      var wind = Wind(speed: 15, direction: "ESE");
      expect(wind.speed, 15);

      // Invalid speed of -1
      expect(() => Wind(speed: -1, direction: "N"), throwsArgumentError);
    });
    test('Test direction', () {
      // Check that our angle calculation is correct
      var wind = Wind(speed: 15, direction: "ENE");
      expect(wind.angle, AngleMatcher(atan2(-1, -2) * 180 / pi));

      wind = Wind(speed: 10, direction: "N");
      expect(wind.angle, AngleMatcher(270));

      // Check that we can handle lowercase
      wind = Wind(speed: 17, direction: "wsw");
      expect(wind.angle, AngleMatcher(atan2(1, 2) * 180 / pi));

      // Test invalid direction
      expect(() => Wind(speed: 10, direction: "ABC"), throwsArgumentError);
    });
  });
}

/// Matcher that compares angles in degrees by mapping them
/// into the [0, 360) range.
class AngleMatcher extends Matcher {
  late final double angle;

  AngleMatcher(double angle) {
    this.angle = _fixAngle(angle);
  }

  @override
  Description describe(Description description) =>
      description.add("$angle deg.");

  @override
  bool matches(item, Map matchState) {
    return _fixAngle(item) == angle;
  }

  double _fixAngle(double angle) {
    while (angle < 0) {
      angle += 360;
    }

    return angle % 360;
  }
}
