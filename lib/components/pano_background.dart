import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:surfapp/animation/springdrag.dart';

class PanoramicBackground extends StatefulWidget {
  final Image image;
  final bool touchEnabled;

  const PanoramicBackground(
      {super.key, required this.image, this.touchEnabled = true});

  @override
  State<PanoramicBackground> createState() => _PanoramicBackgroundState();
}

class _PanoramicBackgroundState extends State<PanoramicBackground>
    with SingleTickerProviderStateMixin {
  var imageCompleter = Completer<ui.Image>();
  ui.Image? image;
  late Ticker ticker;
  final canvasKey = GlobalKey();
  final SpringDragListener _dragListener = SpringDragListener(
    spring: SpringDescription.withDampingRatio(
      mass: 1.0,
      stiffness: 1.0,
      ratio: 1.0,
    ),
  );

  double displacement = 0;

  @override
  Widget build(BuildContext context) {
    if (isReady && image != null) {
      return GestureDetector(
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: CustomPaint(
          key: canvasKey,
          size: MediaQuery.sizeOf(context),
          painter: PanoramicBackgroundPainter(
            image!,
            displacement: displacement,
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

  void onDragUpdate(DragUpdateDetails details) {
    if (widget.touchEnabled) {
      _dragListener.onDragUpdate(details);
    }
  }

  void onDragStart(DragStartDetails details) {
    if (widget.touchEnabled) {
      _dragListener.onDragStart(details);
    }
  }

  void onDragEnd(DragEndDetails details) {
    if (widget.touchEnabled) {
      _dragListener.onDragEnd(details);
    }
  }

  void updatePosition() {
    var newDisplacement = _dragListener.x.clamp(0.0, 1.0);

    if (newDisplacement != displacement) {
      setState(() => displacement = newDisplacement);
    }
  }

  void _loadImage() {
    Completer<ui.Image> completer = Completer<ui.Image>();
    widget.image.image
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
    }));

    imageCompleter = completer;
    completer.future.then((value) {
      setState(() => image = value);
      _dragListener.reset(newX: 0);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadImage();

    ticker = createTicker((elapsed) {
      updatePosition();
    });
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PanoramicBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) {
      _loadImage();
    }
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
