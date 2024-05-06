import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:surfapp/util.dart';

import '../data/camera_shot.dart';
import '../services/beachcam.dart';

/// Widget that allows the user to pick a [CameraShot] from
/// the available shots given by the [BeachCamService].
///
/// It features a floating action button that, when pressed, shows
/// a list of available options. If the user picks one, it notifies
/// any widgets holding the [ValueNotifier] of this widget, then hides
/// the list.
class CameraShotSelector extends StatefulWidget {
  /// Notifier that gets user selected camera shot
  final ValueNotifier<CameraShot>? notifier;

  const CameraShotSelector({super.key, this.notifier});

  @override
  State<StatefulWidget> createState() => CameraShotSelectorState();
}

class CameraShotSelectorState extends State<CameraShotSelector> {
  /// Controls displaying the list of available camera shots for
  /// the user to pick
  var showList = false;

  /// All available camera shots
  var availableShots = <CameraShot>[];

  /// The particular shot selected by the user
  var selectedShot = CameraShot.auto;

  /// The task of refreshing our camera shots
  var refreshTask = CancelableOperation.fromValue(<CameraShot>[]);

  /// Timer for refreshing our camera shots
  late final Timer refreshTimer;

  /// Key for the floating action button
  var buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          // Center button and text within the Row
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                key: buttonKey,
                elevation: 0,
                backgroundColor: Theme.of(context).cardColor,
                hoverElevation: 0,
                shape: const CircleBorder(),
                onPressed: toggleList,
                child: Icon(
                  Icons.videocam_outlined,
                  size: 40,
                  color: Theme.of(context).colorScheme.inverseSurface,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Visibility(
              visible: showList,
              child: Text(
                selectedShot.name,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.inverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: showList,
          child: Row(
            children: [
              const SizedBox(width: 70),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Left-align choices
                children: getChoices()
                    .map(
                      (choice) => TextButton(
                        onPressed: () => chooseShot(choice),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.resolveWith<Color?>(
                                    (states) =>
                                        Theme.of(context).colorScheme.surface)),
                        child: Text(
                          choice.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                      ) as Widget,
                    )
                    .interleaving(const SizedBox(height: 5))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    selectedShot = widget.notifier?.value ?? CameraShot.auto;
    refreshCameraShots();
    refreshTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => refreshCameraShots());
  }

  @override
  void dispose() {
    refreshTask.cancel();
    refreshTimer.cancel();
    super.dispose();
  }

  /// Refreshes the list of available camera shots from the [BeachCamService],
  /// and also picks the best one if [selectedShot] is [CameraShot.auto].
  ///
  /// This notifies the holder of the [widget.notifier].
  void refreshCameraShots() {
    refreshTask = CancelableOperation.fromFuture(BeachCamService().getShots())
      ..then((newShots) => {setState(() => availableShots = newShots)})
      ..then((newShots) {
        if (selectedShot.isAuto) {
          widget.notifier?.value = BeachCamService().pickBestShot(newShots);
        }
      });
  }

  /// Callback for when the user picks a camera shot
  void chooseShot(CameraShot shot) {
    setState(() {
      selectedShot = shot;
      showList = false;
    });

    widget.notifier?.value = shot;
  }

  /// Get a list of choices for the user to pick, excluding
  /// the currently selected one and any shots that are older
  /// than an hour.
  List<CameraShot> getChoices() {
    List<CameraShot> choices = [];

    if (!selectedShot.isAuto) {
      choices.add(CameraShot.auto);
    }

    var now = DateTime.now();
    for (var shot in availableShots) {
      if (selectedShot.name != shot.name &&
          now.difference(shot.time) < const Duration(hours: 1)) {
        choices.add(shot);
      }
    }

    if (choices.length <= 1) {
      return [];
    }

    choices.sort(compareShots);
    return choices;
  }

  /// Callback for showing or hiding the list
  void toggleList() {
    setState(() => showList = !showList);
  }

  /// Compares 2 [CameraShot], sorting them alphabetically
  /// and putting panoramas at the end.
  int compareShots(CameraShot a, CameraShot b) {
    var aIsPanorama = a.name.contains("Panorama");
    var bIsPanorama = b.name.contains("Panorama");

    // Put panoramas at the bottom of the list, otherwise
    // order alphabetically
    if (aIsPanorama && !bIsPanorama) {
      return 1;
    } else if (!aIsPanorama && bIsPanorama) {
      return -1;
    } else {
      return a.name.compareTo(b.name);
    }
  }
}
