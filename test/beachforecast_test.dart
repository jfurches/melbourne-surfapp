import 'package:surfapp/data/conditions.dart';
import 'package:test/test.dart';

void main() {
  group('Test wind', () {
    test('Test angle', () {
      var wind = Wind(speed: 15, direction: "ENE");
      expect(wind.angle, 2 / 3 * 180 + 1 / 3 * 270);
    });
  });
}
