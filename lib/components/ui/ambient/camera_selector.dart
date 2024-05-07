import 'package:flutter/material.dart';

import '../../../data/camera_controller.dart';
import '../../../data/camera_shot.dart';
import '../../../util.dart';

/// Widget that allows the user to pick a [CameraShot] from
/// the [CameraController].
///
/// It features a floating action button that, when pressed, shows
/// a list of available options. If the user picks one, it notifies
/// the [controller], then hides the list.
class CameraShotSelector extends StatefulWidget {
  /// Camera controller
  final CameraController controller;

  const CameraShotSelector({super.key, required this.controller});

  @override
  State<StatefulWidget> createState() => CameraShotSelectorState();
}

class CameraShotSelectorState extends State<CameraShotSelector> {
  /// Controls displaying the list of available camera shots for
  /// the user to pick
  var showList = false;

  late dynamic Function() _newShotsClosure;
  late dynamic Function() _newActiveShotClosure;

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
                widget.controller.activeShot.name,
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
                children: getChoices(widget.controller.availableShots)
                    .map(
                      (choice) => TextButton(
                        onPressed: () => selectShot(choice),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color?>(
                            (states) => Theme.of(context).colorScheme.surface,
                          ),
                        ),
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

  /// Callback for when the user picks a camera shot
  void selectShot(CameraShot shot) {
    setState(() => showList = false);
    widget.controller.activeShot = shot;
  }

  /// Get a list of choices for the user to pick, excluding
  /// the currently selected one
  List<CameraShot> getChoices(List<CameraShot> availableShots) {
    if (availableShots.length <= 1) {
      return [];
    }

    var choices = availableShots
        .where((s) => s.name != widget.controller.activeShot.name)
        .toList();
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

  @override
  void initState() {
    super.initState();
    _newShotsClosure =
        widget.controller.onNewShotsAvailable(onNewShotsAvailable);
    _newActiveShotClosure =
        widget.controller.onActiveShotChange(onNewActiveShot);
  }

  @override
  void dispose() {
    widget.controller.availableShotsNotifier
        .removeListener(_newActiveShotClosure);
    widget.controller.resolvedShotNotifier.removeListener(_newShotsClosure);
    super.dispose();
  }

  void onNewActiveShot(CameraShot newShot) {
    setState(() {/* Potentially new selection */});
  }

  void onNewShotsAvailable(List<CameraShot> newShots) {
    setState(() {/* New shots available, redraw choices */});
  }
}
