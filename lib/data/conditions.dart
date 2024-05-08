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

  Wind({required this.speed, required this.direction}) {
    if (speed < 0) {
      throw ArgumentError("Wind speed cannot be negative");
    }

    if (direction.isEmpty || direction.length > 3) {
      throw ArgumentError("Wind direction must be 1-3 characters long");
    }

    for (var char in direction.toUpperCase().characters) {
      if (!["N", "E", "S", "W"].contains(char)) {
        throw ArgumentError("Invalid wind direction character: $char");
      }
    }
  }

  double get angle {
    // Direction will look like "N" or "ESE"
    var dirToAngle = {"N": 270, "E": 180, "S": 90, "W": 0};
    var windVector = Vector.zero;

    for (var char in direction.toUpperCase().characters) {
      windVector += Vector.fromAngle(dirToAngle[char]!);
    }

    windVector /= direction.length;
    return windVector.angle;
  }
}

class Tide {}
