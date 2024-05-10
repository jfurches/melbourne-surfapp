import 'dart:async';

import '../services/beachcam.dart';
import 'camera_shot.dart';

/// Controller that manages the active camera and available shots
class CameraController {
  var _excludeAfter = const Duration(minutes: 30);

  /// Stream for when new shots are selected
  final _activeShotStream = StreamController<CameraShot>.broadcast();

  /// Currently active shot after resolving
  var _activeShot = CameraShot.auto;

  /// Stream for available shots
  final _availableShotsStream = StreamController<List<CameraShot>>.broadcast();

  /// List of available shots
  final _availableShots = <CameraShot>[];

  /// Timer for fetching new images
  late final Timer _refreshTimer;

  var _newestValidCameraShot = CameraShot.auto;

  CameraController() {
    _refresh();
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 2), (_) => _refresh());
  }

  /// Returns the actively selected (unresolved) shot
  CameraShot get activeShot => _activeShot;

  /// Returns the actively selected (resolved) shot
  CameraShot get resolvedShot => resolve(_activeShot);

  /// Resolves the passed shot and notifies any observers.
  /// This won't update if the passed shot is the same
  set activeShot(CameraShot shot) {
    _activeShot = shot;
    _activeShotStream.add(resolvedShot);
  }

  Duration get maximumShotAge => _excludeAfter;

  set maximumShotAge(Duration value) {
    _excludeAfter = value;
    _refresh();
  }

  /// Returns the best shot (used by Auto mode)
  CameraShot get bestShot {
    try {
      return rankShots(availableShots).where((s) => s.isReal).last;
    } on StateError {
      return _newestValidCameraShot;
    }
  }

  /// Returns all available camera shots
  List<CameraShot> get availableShots => _availableShots.toList();

  /// Fills in the passed shot with the best shot if it's Auto
  CameraShot resolve(CameraShot shot) {
    if (shot.isAuto && !shot.isReal) {
      return CameraShot("Auto", bestShot.url, bestShot.time);
    }

    return shot;
  }

  StreamSubscription<CameraShot> onActiveShotChange(
      Function(CameraShot) callback) {
    return _activeShotStream.stream.listen(callback);
  }

  StreamSubscription<List<CameraShot>> onNewShotsAvailable(
      Function(List<CameraShot>) callback) {
    return _availableShotsStream.stream.listen(callback);
  }

  /// Shot ranking algorithm, used for Auto mode
  ///
  /// Returns shots in ascending order of awesomeness
  List<CameraShot> rankShots(List<CameraShot> shots) {
    // Score each shot using the ranking algorithm
    var scored = shots.map((s) => (scoreShot(s), s)).toList();

    // Sort in ascending order by score, then reverse so that
    // shots with the highest score are first.
    scored.sort((a, b) => a.$1.compareTo(b.$1));
    return scored.map((e) => e.$2).toList();
  }

  /// Scores [shot] based on its metadata.
  ///
  /// Higher is better. Currently it prefers static images
  /// to panoramas, and images that are newer are preferred.
  double scoreShot(CameraShot shot) {
    if (!shot.isReal) {
      return -1;
    }

    // Todo: incorporate directionality and sunrise/sunset to create
    // a more "cinematic" score.

    var points = 1;
    // points += s.name.contains("North") ? 1 : 0;
    // points += s.name.contains("Zoom") ? 1 : 0;
    points += shot.isPanorama ? 0 : 1;
    var multiplier = (1 -
            DateTime.now().difference(shot.time).inMinutes /
                maximumShotAge.inMinutes)
        .clamp(0.0, 1.0);
    return multiplier * points;
  }

  Future<void> _refresh() async {
    var oldShots = _availableShots.toList();

    _availableShots.clear();

    var now = DateTime.now();
    var fetchedShots = await BeachCamService().fetchShots();
    fetchedShots.sort((a, b) => a.time.compareTo(b.time));
    _newestValidCameraShot = fetchedShots.last;

    var newShots = fetchedShots
        .where((s) => now.difference(s.time) < maximumShotAge)
        .toList();

    if (newShots.length >= 2) {
      newShots.add(CameraShot.auto);
    }
    _availableShots.addAll(newShots);

    // Let all observers know we have a fresh batch of shots
    _availableShotsStream.add(_availableShots);

    // Update the selected shot. Using the activeShot setter should
    // notify any listeners
    if (_availableShots.length == 1) {
      activeShot = _availableShots.first;
    } else {
      // If we go from 1 -> 2+ shots, we likely were forced to a single
      // choice. So now we should go auto.
      if (oldShots.length <= 1) {
        activeShot = CameraShot.auto;
      } else {
        // We have an active selection, so try to preserve that by
        // matching name, then returning the new updated version.
        activeShot = _availableShots.firstWhere(
          (shot) => shot.name == _activeShot.name,
          orElse: () => CameraShot.auto,
        );
      }
    }
  }

  /// Closes all resources
  void dispose() {
    _activeShotStream.close();
    _availableShotsStream.close();
    _refreshTimer.cancel();
  }
}
