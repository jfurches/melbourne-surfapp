import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../data/beachconditions.dart';
import '../../../services/surfguru.dart';

/// Card showing current beach conditions
class NowCard extends StatefulWidget {
  const NowCard({super.key});

  @override
  NowCardState createState() => NowCardState();
}

class NowCardState extends State<NowCard> {
  BeachConditions? beachConditions;
  late Timer updateTimer;

  @override
  Widget build(BuildContext context) {
    if (beachConditions == null) {
      return const CircularProgressIndicator();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 175,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _row(
                Icons.tsunami,
                Colors.cyan.shade300,
                _formatSurf(),
              ),
              _row(
                Icons.air,
                Colors.green.shade200,
                "${beachConditions!.wind.speed.toInt()} mph",
                extra: Transform.rotate(
                  // Transform rotates CW for some odd reason
                  angle: -beachConditions!.wind.angle * pi / 180,
                  child: Icon(Icons.arrow_right_alt,
                      color: Colors.green.shade200, size: 30),
                ),
              ),
              _row(
                Icons.thermostat,
                Colors.pink.shade300,
                _formatTemperature(beachConditions!.airTemperature),
              ),
              _row(
                Icons.water,
                Colors.blue.shade300,
                _formatTemperature(beachConditions!.waterTemperature),
              ),
              _row(
                Icons.sunny,
                Colors.yellow.shade300,
                beachConditions!.uvIndex?.toString() ?? 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    update();
    updateTimer = Timer.periodic(const Duration(minutes: 1), (_) => update());
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }

  void update() {
    Surfguru()
        .getCurrentConditions()
        .then((v) => setState(() => beachConditions = v));
  }

  String _formatSurf() {
    var surf = beachConditions!.surf;
    if (surf - surf.floor() > 0) {
      return "${surf.floor()}-${surf.ceil()} ft";
    }

    return "${surf.toInt()} ft";
  }

  String _formatTemperature(double temp) {
    return "${temp.toInt()} °F";
  }

  Widget _row(IconData icon, Color color, String text, {Widget? extra}) {
    var elements = [
      Icon(icon, size: 45, color: color),
      const SizedBox(width: 7),
      Text(text, style: const TextStyle(fontSize: 22))
    ];

    if (extra != null) {
      elements.add(extra);
    }

    return Row(children: elements);
  }
}
