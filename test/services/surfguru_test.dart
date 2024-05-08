import 'package:test/test.dart';
import 'package:surfapp/services/surfguru.dart';

void main() {
  test('Test caching of forecast', () async {
    expect(Surfguru().shouldRefresh(), isTrue);
    await Surfguru().getForecast();
    expect(Surfguru().shouldRefresh(), isFalse);
  });
  test('Test caching of current conditions', () async {
    expect(Surfguru().shouldRefresh(), isTrue);
    await Surfguru().getCurrentConditions();
    expect(Surfguru().shouldRefresh(), isFalse);
  });
  test('Get forecast', () async {
    var conditions = await Surfguru().getForecast();
    expect(conditions.length, 6);

    for (var surf in conditions.surf) {
      expect(surf >= 0, isTrue);
    }
  });
  test('Get current conditions', () async {
    var conditions = await Surfguru().getCurrentConditions();

    // If this isn't true in florida then sue me
    expect(conditions.airTemperature > 0, isTrue);
    expect(conditions.waterTemperature > 0, isTrue);
  });
}
