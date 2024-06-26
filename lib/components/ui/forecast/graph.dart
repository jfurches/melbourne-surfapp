import 'dart:math';

import 'package:equations/equations.dart' show Complex, Cubic;
import 'package:flutter/material.dart' hide Cubic;

import '../../../util.dart';

class GraphWidget extends StatelessWidget {
  final Color color;
  final Series series;
  final double currentPoint;

  const GraphWidget(
      {super.key,
      required this.color,
      required this.series,
      this.currentPoint = -1});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
            children: series.yLabels.reversed
                .map((s) => Text(s, style: const TextStyle(color: Colors.grey))
                    as Widget)
                .interleaving(const Spacer())
                .toList()),
        Expanded(
          child: ClipRect(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: CustomPaint(
                painter: GraphPainter(
                  color: color,
                  series: series,
                  currentPoint: currentPoint,
                ),
                child: Container(),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class GraphPainter extends CustomPainter {
  final Color color;
  final double currentPoint;
  final Series series;

  late final CubicSpline curve;

  GraphPainter({
    required this.color,
    required this.series,
    this.currentPoint = -1,
  }) {
    var normalized = series.normalized;
    var xs = normalized.map((e) => e.$1).toList();
    var ys = normalized
        .map((e) => 1 - e.$2)
        .toList(); // This flips the graph upside down
    curve = CubicSpline(xs, ys);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the axes
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      Paint()..color = Colors.grey.withOpacity(0.5),
    );

    // canvas.drawLine(
    //   Offset.zero,
    //   Offset(0, size.height),
    //   Paint()..color = Colors.grey.withOpacity(0.5),
    // );

    const dx = 0.01;
    var x = 0.0;

    if (currentPoint > 0) {
      var beforePath = Path();
      beforePath.moveTo(x * size.width, curve.compute(x) * size.height);
      while (x <= min(currentPoint + dx, 1)) {
        var px = x * size.width;
        var py = curve.compute(x) * size.height;
        beforePath.lineTo(px, py);
        x += dx;
      }

      canvas.drawPath(
        beforePath,
        Paint()
          ..color = Colors.grey.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0,
      );
    }

    if (currentPoint <= 1) {
      var afterPath = Path();
      x = max(0, currentPoint);
      afterPath.moveTo(x * size.width, curve.compute(x) * size.height);
      while (x <= 1.0) {
        var px = x * size.width;
        var py = curve.compute(x) * size.height;
        afterPath.lineTo(px, py);
        x += dx;
      }

      canvas.drawPath(
        afterPath,
        Paint()
          ..color = color
          ..strokeWidth = 7.0
          ..style = PaintingStyle.stroke,
      );
    }

    if (currentPoint <= 1.0 && currentPoint >= 0.0) {
      var paint = Paint()
        ..color = color
        ..strokeWidth = 7.0
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(currentPoint * size.width,
            curve.compute(currentPoint) * size.height),
        7,
        paint,
      );

      canvas.drawCircle(
        Offset(currentPoint * size.width,
            curve.compute(currentPoint) * size.height),
        13,
        paint..color = color.withOpacity(0.2),
      );
    }
  }

  @override
  bool shouldRepaint(GraphPainter oldDelegate) {
    return currentPoint > oldDelegate.currentPoint;
  }
}

class Series {
  List<double> xValues;
  List<String> xLabels;
  List<double> yValues;
  List<String> yLabels;
  final List<(double, double)> data;

  List<(double, double)> get normalized {
    // Normalize the data to 0-1
    var minX = data.map((e) => e.$1).reduce(min);
    var maxX = data.map((e) => e.$1).reduce(max);
    var minY = data.map((e) => e.$2).reduce(min);
    var maxY = data.map((e) => e.$2).reduce(max);

    var newData = <(double, double)>[];
    for (var i = 0; i < xValues.length; i++) {
      var point = data[i];
      var newX = (point.$1 - minX) / (maxX - minX);
      var newY = (point.$2 - minY) / (maxY - minY);

      newData.add((newX, newY));
    }

    return newData;
  }

  Series(
      {required this.data,
      this.xValues = const [],
      this.xLabels = const [],
      this.yValues = const [],
      this.yLabels = const []}) {
    // Validate the input data
    if (xValues.isEmpty && xLabels.isEmpty) {
      throw ArgumentError('xValues and xLabels cannot both be empty');
    }

    if (yValues.isEmpty && yLabels.isEmpty) {
      throw ArgumentError('yValues and yLabels cannot both be empty');
    }

    // Now construct the data based on the input
    if (xValues.isEmpty) {
      xValues = List.generate(
          xLabels.length, (index) => index.toDouble() / xLabels.length);
    } else if (xLabels.isEmpty) {
      xLabels = xValues.map((e) => e.toString()).toList();
    }

    if (yValues.isEmpty) {
      yValues = List.generate(
          yLabels.length, (index) => index.toDouble() / yLabels.length);
    } else if (yLabels.isEmpty) {
      yLabels = yValues.map((e) => e.toString()).toList();
    }
  }
}

class CubicSpline {
  final List<double> xs;
  final List<double> ys;

  final List<Cubic> _splines = [];

  CubicSpline(this.xs, this.ys) {
    if (xs.length != ys.length) {
      throw ArgumentError("xs and ys must have the same length.");
    }

    _computeSplines();
  }

  double compute(double x) {
    int index = _findIndex(x);
    double t = (x - xs[index]);
    return max(0.01, min(0.99, _splines[index].realEvaluateOn(t).real));
  }

  // double _getDerivative(int i) {
  //   if (i == 0) {
  //     // Natural spline - zero second derivative at the first endpoint
  //     return 0.0;
  //   } else if (i == xs.length - 1) {
  //     // Natural spline - zero second derivative at the last endpoint
  //     return 0.0;
  //   } else {
  //     // Calculate derivative using finite difference formula
  //     return (ys[i + 1] - ys[i - 1]) / (xs[i + 1] - xs[i - 1]);
  //   }
  // }

  int _findIndex(double x) {
    if (x < xs[0] || x > xs[xs.length - 1]) {
      throw ArgumentError("x is outside the range of the spline");
    }
    for (int i = 0; i < xs.length - 1; i++) {
      if (x >= xs[i] && x <= xs[i + 1]) {
        return i;
      }
    }
    return -1; // Should not reach here
  }

  void _computeSplines() {
    var n = ys.length - 1;
    var a = ys.toList(growable: false);
    var b = List<double>.filled(n, 0.0, growable: false);
    var d = List<double>.filled(n, 0.0, growable: false);
    var h = List.generate(n, (i) => xs[i + 1] - xs[i], growable: false);

    var alpha = List.generate(n, (i) {
      if (i == 0) {
        return 0;
      }

      return 3 / h[i] * (a[i + 1] - a[i]) - 3 / h[i - 1] * (a[i] - a[i - 1]);
    });

    var c = List<double>.filled(n + 1, 0.0, growable: false);
    var l = List<double>.filled(n + 1, 0.0, growable: false);
    var mu = List<double>.filled(n + 1, 0.0, growable: false);
    var z = List<double>.filled(n + 1, 0.0, growable: false);

    l[0] = 1;

    for (var i = 1; i < n; i++) {
      l[i] = 2 * (xs[i + 1] - xs[i - 1]) - h[i - 1] * mu[i - 1];
      mu[i] = h[i] / l[i];
      z[i] = (alpha[i] - h[i - 1] * z[i - 1]) / l[i];
    }

    l[n] = 1;

    for (var j = n - 1; j >= 0; j--) {
      c[j] = z[j] - mu[j] * c[j + 1];
      b[j] = (a[j + 1] - a[j]) / h[j] - h[j] * (c[j + 1] + 2 * c[j]) / 3;
      d[j] = (c[j + 1] - c[j]) / (3 * h[j]);
    }

    for (var i = 0; i < n; i++) {
      Cubic si = Cubic(
        // We have to flip the coefficients
        a: Complex.fromReal(d[i]),
        b: Complex.fromReal(c[i]),
        c: Complex.fromReal(b[i]),
        d: Complex.fromReal(a[i]),
      );
      _splines.add(si);
    }
  }
}
