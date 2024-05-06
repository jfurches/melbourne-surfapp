import 'package:test/test.dart';
import 'package:surfapp/services/surfguru.dart';

void main() {
  test('Get current conditions', () async {
    var conditions = await Surfguru().getForecast();
    expect(conditions.length, 6);
  });
}
