import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../data/camera_controller.dart';
import '../../data/camera_shot.dart';
import 'panoramic.dart';
import 'static.dart';

class BeachCamBackground extends StatefulWidget {
  final CameraController controller;
  final bool touchEnabled;

  const BeachCamBackground({
    super.key,
    required this.controller,
    this.touchEnabled = true,
  });

  @override
  State<StatefulWidget> createState() => BeachCamBackgroundState();
}

class BeachCamBackgroundState extends State<BeachCamBackground> {
  late StreamSubscription<CameraShot> _subscription;

  @override
  Widget build(BuildContext context) {
    var shot = widget.controller.resolvedShot;
    if (shot.isReal) {
      return getForShot(shot);
    } else {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blurred_beach.png'),
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _subscription = widget.controller.onActiveShotChange(onNewShot);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  void onNewShot(CameraShot shot) {
    setState(() {});
  }

  Widget getForShot(CameraShot shot) {
    var image = Image.network(shot.url.toString());

    if (shot.isPanorama) {
      return PanoramicBackground(
          image: image, touchEnabled: widget.touchEnabled);
    } else {
      return StaticBackground(image: image);
    }
  }
}
