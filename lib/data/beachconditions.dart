import 'conditions.dart';

class BeachConditions {
  final double surf;
  final Wind wind;
  final Weather weather;
  final double waterTemperature;
  final int? uvIndex;

  const BeachConditions({
    required this.surf,
    required this.wind,
    required this.weather,
    required this.waterTemperature,
    required this.uvIndex,
  });

  double get airTemperature => weather.temperature;
}
