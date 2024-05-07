import 'dart:math';

import 'package:flutter/material.dart';

import '../graph.dart';
import '../../../../data/beachforecast.dart';
import '../../../../util.dart';
import 'graph_card.dart';

final numberPattern = RegExp(r"\d+");

class TemperatureCard extends StatelessWidget {
  final BeachForecast beachConditions;
  const TemperatureCard({super.key, required this.beachConditions});

  @override
  Widget build(BuildContext context) {
    return GraphCard(
      title: "Temperature",
      iconData: Icons.thermostat,
      iconColor: Colors.pink.shade300,
      graph: GraphWidget(
        color: Colors.pink.shade300,
        series: getSeries(),
        currentPoint: currentTime(),
      ),
    );
  }

  Series getSeries() {
    List<(double, double)> data = [];
    var hours = beachConditions.times.map((t) => t.hour).toList();
    var temps = beachConditions.weather.map((w) => w.temperature).toList();

    for (var i = 0; i < hours.length; i++) {
      data.add((hours[i] * 1.0, temps[i]));
    }

    var xLabels = beachConditions.times.map(displayTime).toList();
    var xValues = hours.map((h) => h * 1.0).toList();
    var yValues = [temps.reduce(min), temps.reduce(max)];

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
