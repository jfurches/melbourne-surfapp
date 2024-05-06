import 'package:flutter/widgets.dart';

import '../util/vector.dart';

class Weather {
  final double temperature;
  final double rainChance;

  Weather({required this.temperature, required this.rainChance});
}

class Wind {
  final double speed;
  final String direction;

  Wind({required this.speed, required this.direction});

  double get angle {
    // Direction will look like "N" or "ESE"
    var dirToAngle = {"N": 270, "E": 180, "S": 90, "W": 0};
    var windVector = Vector.zero;

    for (var char in direction.characters) {
      windVector += Vector.fromAngle(dirToAngle[char]!);
    }

    windVector /= direction.length;
    return windVector.angle;
  }
}

class Tide {}
