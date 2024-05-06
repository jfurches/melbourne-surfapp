import 'conditions.dart';

/// Class representing the forecasted beach conditions for the day
///
/// This behaves similarly to a dataframe.
class BeachForecast {
  final List<ForecastRow> _rows = [];

  // Column getters
  List<DateTime> get times => _rows.map((r) => r.time).toList();
  List<double> get surf => _rows.map((r) => r.surf).toList();
  List<String> get swell => _rows.map((r) => r.swell).toList();
  List<Wind> get wind => _rows.map((r) => r.wind).toList();
  List<Weather> get weather => _rows.map((r) => r.weather).toList();

  // Collection-like methods
  bool get isEmpty => _rows.isEmpty;
  bool get isNotEmpty => _rows.isNotEmpty;
  int get length => _rows.length;

  /// Adds a row to the forecast if it's not already present
  void addRow(ForecastRow row) {
    for (var existingRow in _rows) {
      if (existingRow.time == row.time) {
        return;
      }
    }

    _rows.add(row);
  }
}

class ForecastRow {
  // Todo: make proper types for these
  /// The time of the forecast
  DateTime time;

  /// The surf level in feet
  double surf;
  String swell;

  /// The wind speed and direction
  Wind wind;

  /// The temperature and rain chance
  Weather weather;

  ForecastRow(
      {required this.time,
      required this.surf,
      required this.swell,
      required this.wind,
      required this.weather});

  @override
  String toString() {
    return 'Time: $time, Surf: $surf, Swell: $swell, Wind: $wind, Weather: $weather';
  }
}
