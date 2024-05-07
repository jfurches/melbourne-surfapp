import 'package:flutter/widgets.dart';

import '../../data/camera_controller.dart';
import 'ambient/camera_selector.dart';
import 'ambient/now_card.dart';

class AmbientUi extends StatelessWidget {
  final CameraController cameraController;

  const AmbientUi({super.key, required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Current conditions card
        const Positioned(
          bottom: 0,
          left: 0,
          child: NowCard(),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: CameraShotSelector(
            controller: cameraController,
          ),
        ),
      ],
    );
  }
}
