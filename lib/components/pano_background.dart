import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class PanoramicBackground extends StatefulWidget {
  final Image image;
  final bool touchEnabled;

  const PanoramicBackground(
      {super.key, required this.image, this.touchEnabled = true});

  @override
  State<PanoramicBackground> createState() => _PanoramicBackgroundState();
}

class _PanoramicBackgroundState extends State<PanoramicBackground> {
  Completer<ui.Image> imageCompleter = Completer<ui.Image>();
  ui.Image? image;
  double displacement = 0;
  double momentum = 0;
  late Timer ticker;
  final canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (isReady) {
      return GestureDetector(
        onHorizontalDragUpdate: (details) => onDrag(-details.delta.dx),
        child: CustomPaint(
          key: canvasKey,
          size: MediaQuery.sizeOf(context),
          painter: PanoramicBackgroundPainter(
            image!,
            displacement: displacement.toDouble(),
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
  }

  bool get isReady => imageCompleter.isCompleted;

  void onDrag(double dx) {
    if (widget.touchEnabled) {
      momentum += min(0.0005 * dx, 0.05);
    }
  }

  void updatePosition() {
    if (momentum == 0) {
      return;
    }

    var newDisplacement = displacement + momentum;
    newDisplacement = newDisplacement.clamp(0, 1);
    setState(() => displacement = newDisplacement);

    if (momentum.abs() < 0.01) {
      momentum = 0;
      return;
    }

    momentum -= momentum * 0.2;
  }

  @override
  void initState() {
    super.initState();

    Completer<ui.Image> completer = Completer<ui.Image>();
    widget.image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    imageCompleter = completer;
    completer.future.then((value) => setState(() => image = value));

    ticker = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      updatePosition();
    });
  }

  @override
  void dispose() {
    ticker.cancel();
    super.dispose();
  }
}

class PanoramicBackgroundPainter extends CustomPainter {
  final ui.Image image;
  final double displacement;

  Rect srcRect = Rect.zero;
  double resizeFactor = 0;

  PanoramicBackgroundPainter(this.image, {this.displacement = 0});

  @override
  void paint(Canvas canvas, Size size) {
    var src = display(size);
    var dst = Rect.fromLTWH(0, 0, size.width, size.height);

    // Paint image onto canvas
    canvas.drawImageRect(image, src, dst, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Check if the displacement or image changed
    if (oldDelegate is PanoramicBackgroundPainter) {
      return displacement != oldDelegate.displacement ||
          image != oldDelegate.image;
    }

    return true;
  }

  Rect display(Size canvasSize) {
    if (srcRect == Rect.zero) {
      // We'd like to exclude the panorama lines from the initial view
      var maxWidth = image.width / 3;
      var maxFactor = maxWidth / canvasSize.width;

      // Compute the largest vertical centering that both excludes the
      // text in the top left (my = 60) and the panorama line to the right
      var my = max(60.0, (image.height - canvasSize.height * maxFactor) / 2);
      var y = my;
      var h = image.height - my * 2;
      resizeFactor = h / canvasSize.height;

      // Use the factor to compute the width, then return the rectangle
      var w = resizeFactor * canvasSize.width;
      srcRect = Rect.fromLTWH(0, y, w, h);
    }

    return srcRect.translate(displacement * maxDisplacement, 0);
  }

  double get maxDisplacement {
    return (image.width - srcRect.width);
  }
}
