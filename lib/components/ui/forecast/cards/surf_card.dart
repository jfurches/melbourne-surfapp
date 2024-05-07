import 'dart:math';

import 'package:flutter/material.dart';
import 'package:surfapp/util.dart';

import '../graph.dart';
import '../../../../data/beachforecast.dart';
import 'graph_card.dart';

class SurfCard extends StatelessWidget {
  final BeachForecast beachConditions;
  const SurfCard({super.key, required this.beachConditions});

  @override
  Widget build(BuildContext context) {
    return GraphCard(
      title: "Surf Height",
      iconData: Icons.tsunami,
      iconColor: Colors.cyan.shade300,
      graph: GraphWidget(
        color: Colors.cyan.shade300,
        series: getSeries(),
        currentPoint: currentTime(),
      ),
    );
  }

  Series getSeries() {
    List<(double, double)> data = [];
    var hours = beachConditions.times.map((t) => t.hour).toList();
    var waves = beachConditions.surf;

    for (var i = 0; i < hours.length; i++) {
      data.add((hours[i] * 1.0, waves[i]));
    }

    var xLabels = beachConditions.times.map(displayTime).toList();
    var xValues = hours.map((h) => h * 1.0).toList();
    var yValues = [waves.reduce(min), waves.reduce(max)];

    return Series(
      data: data,
      xValues: xValues,
      xLabels: xLabels,
      // yLabels: yValues.map((e) => e.toInt().toString()).toList(),
      yValues: yValues,
    );
  }

  double currentTime() {
    var now = DateTime.now();
    var time = now.hour + now.minute / 60;

    var hours = beachConditions.times.map((t) => t.hour).toList();
    var start = hours.reduce(min);
    var end = hours.reduce(max);

    return (time - start) / (end - start);
  }
}
