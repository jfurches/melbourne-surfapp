import 'dart:math';

class Vector {
  final List<double> v;

  Vector._(this.v);

  factory Vector(num x, num y) {
    return Vector._([x.toDouble(), y.toDouble()]);
  }

  factory Vector.of(List<double> v) {
    return Vector._(v.toList()); // copy data
  }

  int get length => v.length;
  double get x => v[0];
  double get y => v[1];

  Vector operator +(Vector v) {
    return Vector._(List.generate(length, (i) => this.v[i] + v.v[i]));
  }

  Vector operator -(Vector v) {
    return Vector._(List.generate(length, (i) => this.v[i] - v.v[i]));
  }

  Vector operator *(num s) {
    return Vector._(List.generate(length, (i) => v[i] * s));
  }

  Vector operator /(num s) {
    return Vector._(List.generate(length, (i) => v[i] / s));
  }

  double get sqrMagnitude {
    return v.reduce((a, b) => a + b * b);
  }

  double get magnitude {
    return sqrt(sqrMagnitude);
  }

  Vector get normalized {
    return this / magnitude;
  }

  double get angle {
    if (length != 2) {
      throw Exception("Vector must be 2D");
    }

    return atan2(y, x) * 180 / pi;
  }

  static Vector fromAngle(num degrees) {
    return Vector(cos(degrees * pi / 180), sin(degrees * pi / 180));
  }

  static Vector get zero => Vector(0, 0);

  @override
  String toString() =>
      "Vector(${v.map((e) => e.toStringAsFixed(2)).join(', ')})";
}
