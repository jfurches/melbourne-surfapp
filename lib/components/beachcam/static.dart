import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class StaticBackground extends StatefulWidget {
  final Image image;

  const StaticBackground({super.key, required this.image});

  @override
  State<StatefulWidget> createState() => StaticBackgroundState();
}

class StaticBackgroundState extends State<StaticBackground>
    with TickerProviderStateMixin {
  final animationDuration = const Duration(milliseconds: 500);
  final blurSigma = 15.0;

  double blurAmount = 0;
  ImageProvider? _currentImage;
  var imageCompleter = Completer<ui.Image>();

  late final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                _currentImage ?? const AssetImage('assets/blurred_beach.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      builder: (context, child) {
        return ImageFiltered(
          imageFilter: ui.ImageFilter.blur(
            sigmaX: controller.value * blurSigma,
            sigmaY: controller.value * blurSigma,
          ),
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      value: 1.0,
      vsync: this,
      duration: animationDuration,
    );

    _loadImage(widget.image);
  }

  @override
  void didUpdateWidget(StaticBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    const config = ImageConfiguration();
    var f1 = oldWidget.image.image.obtainKey(config);
    var f2 = widget.image.image.obtainKey(config);

    f1.then((k1) => f2.then((k2) {
          if (k1 != k2) {
            _loadImage(widget.image);
          }
        }));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _loadImage(Image image) {
    // Blur while loading
    var animationFuture = controller.animateTo(1.0);

    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    // Unlike in panoramic, we just wait for it to load, but we won't
    // handle the raw ui.image
    imageCompleter = completer;
    completer.future.then((value) {
      animationFuture.whenComplete(() {
        setState(() {
          _currentImage = image.image;
        });

        controller.animateTo(0);
      });
    });
  }
}
