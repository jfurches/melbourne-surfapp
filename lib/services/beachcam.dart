import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;

import '../data/camera_shot.dart';

/// Service that handles retrieving beach cam images from
/// www.sebastianinletcam.com website.
class BeachCamService {
  static final BeachCamService _instance = BeachCamService._internal();
  factory BeachCamService() => _instance;

  /// How long to wait before making a subsequent call
  final Duration refreshAfter = const Duration(minutes: 5);

  /// Time of the last call
  DateTime _lastRefresh = DateTime.now();

  /// Current set of available [CameraShot]
  List<CameraShot> _cameraShots = [];

  /// Internal map that associates seemingly random camera
  /// variable names with the actual name, e.g. s24 -> North Zoom.
  /// This is populated during the web request by parsing the webpage.
  Map<String, String> _varIdMap = {};

  BeachCamService._internal() {
    _lastRefresh = DateTime.now().subtract(refreshAfter);
  }

  /// Determines if we should make a web request to get
  /// the latest data. Currently happens when:
  /// - There are no available camera shots
  /// - After [refreshAfter] time has passed since the last refesh
  bool shouldRefresh() =>
      _cameraShots.isEmpty ||
      DateTime.now().isAfter(_lastRefresh.add(refreshAfter));

  /// Gets all available shots, refreshing if necessary.
  Future<List<CameraShot>> fetchShots() async {
    if (shouldRefresh()) {
      await _refresh();
    }

    return _cameraShots;
  }

  /// Refreshes our data by making a request to get the latest
  /// uploads. Populates [_varIdMap] if it's empty.
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

      // Parse the data for this shot. Its date is given in seconds
      // since the epoch, and for some reason the url always has
      // backslashes escaping the forward slashes.
      var time = DateTime.fromMillisecondsSinceEpoch(
          entry.value["timestamp"] * 1000 as int);
      var uriPath = (entry.value['hr'] as String).replaceAll(r"\", "");

      shots.add(CameraShot(name, Uri.https(dataUrl.authority, uriPath), time));
    }

    _cameraShots = shots;
  }

  /// Makes a request to the main webpage in order to
  /// populate the variable map.
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
}
