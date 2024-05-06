import 'package:flutter/material.dart';

import '../services/beachcam.dart';

class CameraShotSelection extends StatefulWidget {
  final List<CameraShot> shots;
  final ValueNotifier<CameraShot>? notifier;

  const CameraShotSelection({super.key, required this.shots, this.notifier});

  @override
  State<StatefulWidget> createState() => CameraShotSelectionState();
}

class CameraShotSelectionState extends State<CameraShotSelection> {
  bool showList = false;
  CameraShot selectedShot = CameraShot.auto;
  var buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    selectedShot = widget.notifier?.value ?? CameraShot.auto;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
      children: [
        Row(
          // Center button and text within the Row
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: FloatingActionButton(
                key: buttonKey,
                elevation: 0,
                backgroundColor: Theme.of(context).cardColor,
                // hoverColor: Theme.of(context).cardColor, // Optional
                hoverElevation: 0,
                shape: const CircleBorder(),
                onPressed: onPressed,
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
              const SizedBox(width: 60),
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
                                  (states) {
                            if (states.contains(MaterialState.hovered)) {
                              return Theme.of(context).colorScheme.surface;
                            }
                            return null;
                          }),
                        ),
                        child: Text(
                          choice.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.inverseSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void chooseShot(CameraShot shot) {
    setState(() {
      selectedShot = shot;
      showList = false;
    });

    widget.notifier?.value = shot;
  }

  List<CameraShot> getChoices() {
    List<CameraShot> choices = [];

    var now = DateTime.now();
    for (var shot in widget.shots) {
      if (selectedShot.name != shot.name &&
          now.difference(shot.time) < const Duration(hours: 1)) {
        choices.add(shot);
      }
    }

    if (choices.length <= 1) {
      return [];
    }

    choices.sort((a, b) {
      var aIsPanorama = a.name.contains("Panorama");
      var bIsPanorama = b.name.contains("Panorama");

      if (aIsPanorama && !bIsPanorama) {
        return 1;
      } else if (!aIsPanorama && bIsPanorama) {
        return -1;
      } else {
        return a.name.compareTo(b.name);
      }
    });
    return choices;
  }

  void onPressed() {
    setState(() => showList = !showList);
  }
}

class CameraShotSelectionWrapper extends StatelessWidget {
  final Future<List<CameraShot>> future;
  final ValueNotifier<CameraShot>? notifier;

  const CameraShotSelectionWrapper(
      {super.key, required this.future, this.notifier});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return CameraShotSelection(shots: snapshot.data!, notifier: notifier);
        }

        return const CameraShotSelection(shots: []);
      },
    );
  }
}
