import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SpringDragListener {
  final SpringDescription spring;
  final double minX;
  final double maxX;

  SpringDragListener({required this.spring, this.minX = 0.0, this.maxX = 1.0});

  SpringSimulation? _simulation;
  double _x = 0;
  double _v = 0;
  DateTime _lastTime = DateTime.now();

  double get x {
    if (_simulation != null) {
      var t = (DateTime.now().difference(_lastTime)).inMilliseconds / 1000.0;
      var xVal = _simulation!.x(t);

      if (xVal.isNaN) {
        throw StateError("x is nan");
      }

      // If we go out of bounds, stop the simulation
      if (xVal < minX || xVal > maxX) {
        xVal = xVal.clamp(minX, maxX);
        _x = xVal;
        _v = 0;
        _simulation = null;
        return xVal;
      }

      if (_simulation!.isDone(t)) {
        _resetSimulation();
        return _x;
      }

      return xVal;
    } else if (_v.abs() > 0.001) {
      var dt = (DateTime.now().difference(_lastTime)).inMilliseconds / 1000.0;
      _x = (_x + _v * dt).clamp(minX, maxX);
      _lastTime = DateTime.now();
    }

    return _x;
  }

  void _resetSimulation() {
    var t = (DateTime.now().difference(_lastTime)).inMilliseconds / 1000.0;
    var newX = _simulation!.x(t);
    if (!newX.isNaN) {
      _x = newX.clamp(minX, maxX);
    }

    _v = 0;
    _simulation = null;
  }

  void onDragStart(DragStartDetails details) {
    // Switch to manual control
    if (_simulation != null) {
      _resetSimulation();
    }

    _lastTime = DateTime.now();
  }

  void onDragUpdate(DragUpdateDetails details) {
    // Set the velocity
    var dt = (DateTime.now().difference(_lastTime)).inMilliseconds / 1000.0;
    _v = -details.delta.dx / dt / 1000; // minus sign to orient properly
    _v = _v.clamp(-0.5, 0.5);
    _lastTime = DateTime.now();
  }

  void onDragEnd(DragEndDetails details) {
    if (_simulation != null) {
      _resetSimulation();
    }

    var v = -(details.primaryVelocity ?? 0) / 1000;
    v = v.clamp(-0.5, 0.5);
    // var ds = v / sqrt(spring.mass / spring.stiffness);
    var ds = v * const Duration(seconds: 1).inMilliseconds / 1000;
    var end = _x + ds;

    if (end != _x) {
      _simulation = SpringSimulation(spring, _x, end, v);
    }

    _lastTime = DateTime.now();
  }
}
