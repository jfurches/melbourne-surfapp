import 'package:flutter/widgets.dart';

import '../../data/camera_shot.dart';
import 'panoramic.dart';
import 'static.dart';

class BeachCamBackground extends StatefulWidget {
  final CameraShot shot;
  final bool touchEnabled;

  const BeachCamBackground({
    super.key,
    required this.shot,
    this.touchEnabled = true,
  });

  @override
  State<StatefulWidget> createState() => BeachCamBackgroundState();
}

class BeachCamBackgroundState extends State<BeachCamBackground> {
  CameraShot lastRealShot = CameraShot.none;

  @override
  Widget build(BuildContext context) {
    if (lastRealShot.isReal) {
      return getForShot(lastRealShot);
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
    processShot(widget.shot);
  }

  @override
  void didUpdateWidget(BeachCamBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    processShot(widget.shot);
  }

  void processShot(CameraShot shot) {
    if (shot.isReal && shot != lastRealShot) {
      setState(() => lastRealShot = shot);
    }
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
