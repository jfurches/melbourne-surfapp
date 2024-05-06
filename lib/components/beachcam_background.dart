import 'package:flutter/widgets.dart';

import '../data/camera_shot.dart';
import '../services/beachcam.dart';
import 'pano_background.dart';

class BeachCamBackground extends StatelessWidget {
  final CameraShot? shot;
  final bool touchEnabled;

  const BeachCamBackground({
    super.key,
    this.shot,
    this.touchEnabled = true,
  });

  Widget getForShot(CameraShot shot) {
    var image = Image.network(shot.url.toString());

    if (shot.isPanorama) {
      return getPanoramaBackground(image);
    } else {
      return getStaticBackground(image);
    }
  }

  Widget getStaticBackground(Image image) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: image.image,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium),
      ),
    );
  }

  Widget getPanoramaBackground(Image image) {
    return PanoramicBackground(image: image, touchEnabled: touchEnabled);
  }

  @override
  Widget build(BuildContext context) {
    if (shot != null && shot!.url.hasAuthority && shot!.url.hasAbsolutePath) {
      return getForShot(shot!);
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
}
