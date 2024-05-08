import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:surfapp/data/beachconditions.dart';

import '../data/beachforecast.dart';
import '../data/conditions.dart';

class Surfguru {
  static final Surfguru _instance = Surfguru._internal();

  factory Surfguru() => _instance;

  final Duration refreshAfter = const Duration(minutes: 5);
  DateTime _lastUpdated = DateTime.now();

  BeachForecast? _currentForecast;
  BeachConditions? _currentConditions;

  bool shouldRefresh() =>
      _currentForecast == null ||
      DateTime.now().isAfter(_lastUpdated.add(refreshAfter));

  Surfguru._internal();

  Future<BeachConditions> getCurrentConditions() async {
    if (shouldRefresh()) {
      await _refresh();
    }

    return _currentConditions!;
  }

  Future<BeachForecast> getForecast() async {
    if (shouldRefresh()) {
      await _refresh();
    }

    return _currentForecast!;
  }

  Future<void> _refresh() async {
    var url = Uri.https('www.surfguru.com', '/melbourne-beach-surf-report');
    var response = await http.get(url);
    var document = parse(response.body);

    var contentMain = document.querySelector("#contentMain");

    if (contentMain == null) {
      return;
    }

    var currentStatus = contentMain.querySelector("div.main");
    if (currentStatus != null) {
      _currentConditions = _parseConditions(currentStatus);
    }

    // Parse the forecast for the day
    var currentDay =
        document.querySelector("#forecast-details > .forecast-day");
    if (currentDay != null) {
      _currentForecast = _parseForecast(currentDay);
    }

    _lastUpdated = DateTime.now();
  }

  BeachConditions _parseConditions(Element currentStatus) {
    var raw = <String, String>{};
    var headers = currentStatus.querySelectorAll(".report-block > h2");

    for (var header in headers) {
      var name = header.text.trim();
      var value = header.nextElementSibling!.text.trim();
      raw[name] = value;
    }

    var waveHeights = RegExp(r"\d+")
        .allMatches(raw['surf'] ?? "")
        .map((m) => double.parse(m.group(0)!))
        .toList();
    var surf = waveHeights.reduce((a, b) => a + b) / waveHeights.length;

    var wind = _parseWind(raw['wind'] ?? '');
    var airTemperature = double.parse(
        RegExp(r"\d+").firstMatch(raw['weather'] ?? '')!.group(0)!);

    var waterTemperature =
        double.parse(RegExp(r"\d+").firstMatch(raw['water'] ?? '')!.group(0)!);

    var uvIndex = int.tryParse(
        RegExp(r'NA|\d+').firstMatch(raw['uv index'] ?? '')!.group(0)!);

    return BeachConditions(
      surf: surf,
      wind: wind,
      weather: Weather(temperature: airTemperature, rainChance: 0),
      waterTemperature: waterTemperature,
      uvIndex: uvIndex,
    );
  }

  BeachForecast _parseForecast(Element currentDay) {
    var beachForecast = BeachForecast();
    var forecastRows =
        currentDay.querySelectorAll('.forecast-row, .forecast-row-alt');

    for (var row in forecastRows) {
      var time = row.querySelector('.forecast-time')?.text.trim() ?? '';
      var surf = row.querySelector('.forecast-surf')?.text.trim() ?? '';
      var swell =
          row.querySelector('.forecast-swell-primary')?.text.trim() ?? '';
      var wind = row.querySelector('.forecast-wind')?.text.trim() ?? '';
      var weather = row.querySelector('.forecast-weather')?.text.trim() ?? '';

      beachForecast.addRow(ForecastRow(
        time: _parseTime(time),
        surf: _parseSurf(surf),
        swell: swell,
        wind: _parseWind(wind),
        weather: _parseWeather(weather),
      ));
    }

    return beachForecast;
  }

  DateTime _parseTime(String time) {
    var pattern = RegExp(r'(\d{1,2})(am|pm)');
    var match = pattern.firstMatch(time);

    if (match == null) {
      return DateTime.now();
    }

    var hour = int.parse(match.group(1)!);

    if (match.group(2) == 'pm') {
      hour += 12;
    }

    var now = DateTime.now();
    var todayAtMidnight = DateTime(now.year, now.month, now.day);
    return todayAtMidnight.add(Duration(hours: hour));
  }

  Wind _parseWind(String wind) {
    var pattern = RegExp(r'(\d{1,2})\s*mph\s*([NESW]{1,3})');
    var match = pattern.firstMatch(wind);

    if (match == null) {
      return Wind(speed: 0, direction: 'N');
    }

    return Wind(
        speed: double.parse(match.group(1)!), direction: match.group(2)!);
  }

  Weather _parseWeather(String weather) {
    var pattern = RegExp(r'\d{1,3}');
    var match = pattern.firstMatch(weather);

    if (match == null) {
      return Weather(temperature: 0.0, rainChance: 0.0);
    }

    // Todo: obtain rain chance somehow
    var temperature = double.parse(match.group(0)!);
    return Weather(temperature: temperature, rainChance: 0.0);
  }

  double _parseSurf(String surf) {
    var pattern = RegExp(r'([\d\-]+)ft');
    var match = pattern.firstMatch(surf);

    if (match == null) {
      return 0.0;
    }

    surf = match.group(1)!;
    if (surf.contains('-')) {
      var split = surf.split('-').take(2);
      return 0.5 * (double.parse(split.first) + double.parse(split.last));
    }

    return double.parse(surf);
  }
}
