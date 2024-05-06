import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

class BeachCamService {
  static final BeachCamService _instance = BeachCamService._internal();
  factory BeachCamService() => _instance;

  final Duration _refreshInterval = const Duration(minutes: 5);
  DateTime _lastRefresh = DateTime.now();
  List<CameraShot> _lastShots = [];
  Map<String, String> _varIdMap = {};

  BeachCamService._internal() {
    _lastRefresh = DateTime.now().subtract(_refreshInterval);
  }

  bool shouldRefresh() =>
      _lastShots.isEmpty ||
      DateTime.now().isAfter(_lastRefresh.add(_refreshInterval));

  Future<CameraShot> pickBestShot() async {
    if (shouldRefresh()) {
      await _refresh();
    }

    return _rankShots(_lastShots).first;
  }

  Future<CameraShot> getShot(String name) async {
    if (shouldRefresh()) {
      await _refresh();
    }

    if (_lastShots.isEmpty) {
      return CameraShot.none;
    }

    if (name.toLowerCase() == "auto") {
      return await pickBestShot();
    }

    return _lastShots.firstWhere((element) => element.name == name);
  }

  Future<List<CameraShot>> getShots() async {
    if (shouldRefresh()) {
      await _refresh();
    }

    return _lastShots;
  }

  Future<void> _refresh() async {
    if (_varIdMap.isEmpty) {
      _varIdMap = await _getVarIdMap();
    }

    var shots = <CameraShot>[];

    // Make new request to get the images
    // https://www.sebastianinletcam.com/latest.json
    var dataUrl = Uri.https(
      'www.sebastianinletcam.com',
      '/latest.json',
      {
        'q': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    var response = await http.get(dataUrl);
    var paths = jsonDecode(response.body) as Map<String, dynamic>;

    for (var entry in paths.entries) {
      var name = _varIdMap[entry.key];

      if (name == null) {
        continue;
      }

      var time = DateTime.fromMillisecondsSinceEpoch(
          entry.value["timestamp"] * 1000 as int);
      var uriPath = (entry.value['hr'] as String).replaceAll(r"\", "");

      shots.add(CameraShot(name, Uri.https(dataUrl.authority, uriPath), time));
    }

    _lastShots = shots;
  }

  Future<Map<String, String>> _getVarIdMap() async {
    Map<String, String> result = {};

    var pageUrl = Uri.https('www.sebastianinletcam.com');
    var response = await http.get(pageUrl);
    var document = parse(response.body);

    var headers = document.querySelectorAll('h3');
    for (var header in headers) {
      var name = header.innerHtml;
      var galleryElement = header.nextElementSibling!;
      var linkElement = galleryElement.querySelector("a");

      if (linkElement != null) {
        var varId = linkElement.attributes['id']?.split('_').first;

        if (varId == null) {
          continue;
        }

        result[varId] = name;
      }
    }

    return result;
  }

  List<CameraShot> _rankShots(List<CameraShot> shots) {
    // First make a copy
    var scored = shots.map((s) {
      var points = 1;
      points += s.name.contains("North") ? 1 : 0;
      points += s.name.contains("Zoom") ? 1 : 0;
      points += s.isPanorama ? 1 : 0;
      var multiplier = 1 - DateTime.now().difference(s.time).inMinutes / 60;
      return (multiplier * points, s);
    }).toList();
    scored.sort((a, b) => a.$1.compareTo(b.$1));

    return scored.reversed.map((e) => e.$2).toList();
  }
}

class CameraShot {
  final String name;
  final Uri url;
  final DateTime time;

  CameraShot(this.name, this.url, this.time);

  bool get isPanorama => name.contains("Panorama");
  bool get isAuto => name == "Auto";

  static CameraShot get none =>
      CameraShot("", Uri(), DateTime.fromMillisecondsSinceEpoch(0));
  static CameraShot get auto => CameraShot("Auto", Uri(), DateTime.now());

  @override
  String toString() => 'CameraShot{name: $name, time: $time}';
}
