import 'package:flutter/widgets.dart';

import '../services/beachcam.dart';
import 'pano_background.dart';

class BeachCamBackground extends StatelessWidget {
  final CameraShot? shot;
  final Widget child;
  final bool touchEnabled;

  const BeachCamBackground(
      {super.key, this.shot, required this.child, this.touchEnabled = true});

  Widget getForShot(CameraShot shot) {
    var image = Image.network(shot.url.toString());

    if (shot.isPanorama) {
      return getPanoramaBackground(image, child);
    } else {
      return getStaticBackground(image, child);
    }
  }

  Widget getStaticBackground(Image image, Widget? child) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image.image,
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }

  Widget getPanoramaBackground(Image image, Widget? child) {
    return Stack(
      children: [
        PanoramicBackground(image: image, touchEnabled: touchEnabled),
        Container(child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shot != null && shot!.url.hasAuthority) {
      return getForShot(shot!);
    } else {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/blurred_beach.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      );
    }
  }
}
