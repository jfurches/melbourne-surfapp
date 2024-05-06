import 'dart:math';

import 'package:flutter/material.dart';

import '../components/statefulfuturebuilder.dart';
import '../data/beachconditions.dart';

class NowCard extends StatelessWidget {
  final BeachConditions beachConditions;

  const NowCard({required this.beachConditions, super.key});

  @override
  Widget build(BuildContext context) {
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
                "${beachConditions.wind.speed.toInt()} mph",
                extra: Transform.rotate(
                  // Transform rotates CW for some odd reason
                  angle: -beachConditions.wind.angle * pi / 180,
                  child: Icon(Icons.arrow_right_alt,
                      color: Colors.green.shade200, size: 30),
                ),
              ),
              _row(
                Icons.thermostat,
                Colors.pink.shade300,
                _formatTemperature(beachConditions.airTemperature),
              ),
              _row(
                Icons.water,
                Colors.blue.shade300,
                _formatTemperature(beachConditions.waterTemperature),
              ),
              _row(
                Icons.sunny,
                Colors.yellow.shade300,
                beachConditions.uvIndex?.toString() ?? 'N/A',
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSurf() {
    var surf = beachConditions.surf;
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

class NowCardWrapper extends StatelessWidget {
  final Future<BeachConditions> future;

  const NowCardWrapper({required this.future, super.key});

  @override
  Widget build(BuildContext context) {
    return StatefulFutureBuilder<BeachConditions>(
      initialFuture: future,
      builder: (context, snapshot, oldData) {
        BeachConditions? data = oldData;
        if (snapshot.hasData && snapshot.data != null) {
          data = snapshot.data;
        }

        if (data != null) {
          return NowCard(beachConditions: data);
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
