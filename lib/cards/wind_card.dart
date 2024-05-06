import 'dart:math';

import 'package:flutter/material.dart';

import '../components/graph.dart';
import '../data/beachforecast.dart';
import '../util.dart';
import 'graphcard.dart';

class WindCard extends StatelessWidget {
  final BeachForecast beachConditions;
  const WindCard({super.key, required this.beachConditions});

  @override
  Widget build(BuildContext context) {
    return GraphCard(
      title: "Wind",
      iconData: Icons.air,
      iconColor: Colors.green.shade200,
      graph: GraphWidget(
        color: Colors.green.shade200,
        series: getSeries(),
        currentPoint: currentTime(),
      ),
    );
  }

  Series getSeries() {
    List<(double, double)> data = [];
    var hours = beachConditions.times.map((t) => t.hour).toList();
    var mph = beachConditions.wind.map((w) => w.speed).toList();

    for (var i = 0; i < hours.length; i++) {
      data.add((hours[i] * 1.0, mph[i]));
    }

    var xLabels = beachConditions.times.map(displayTime).toList();
    var xValues = hours.map((h) => h * 1.0).toList();
    var yValues = [mph.reduce(min), mph.reduce(max)];

    return Series(
      data: data,
      xValues: xValues,
      xLabels: xLabels,
      yLabels: yValues.map((e) => e.toInt().toString()).toList(),
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
