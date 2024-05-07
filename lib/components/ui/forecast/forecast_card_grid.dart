import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import '../../../data/beachforecast.dart';
import '../../../services/surfguru.dart';
import 'cards/surf_card.dart';
import 'cards/wind_card.dart';

class ForecastCardGrid extends StatefulWidget {
  const ForecastCardGrid({super.key});

  @override
  State<ForecastCardGrid> createState() => ForecastCardGridState();
}

class ForecastCardGridState extends State<ForecastCardGrid> {
  BeachForecast? conditions;
  late Timer updateTimer;
  var updateTask = CancelableOperation.fromValue(BeachForecast());

  @override
  Widget build(BuildContext context) {
    if (conditions == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.extent(
      maxCrossAxisExtent: 600,
      padding: EdgeInsets.zero,
      childAspectRatio: 4 / 3,
      children: [
        SurfCard(beachConditions: conditions!),
        WindCard(beachConditions: conditions!),
        // TemperatureCard(beachConditions: conditions),
      ]
          .map(
            (card) => Center(
              child: SizedBox(
                height: 300,
                width: 400,
                child: card,
              ),
            ) as Widget,
          )
          .toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    update();
    updateTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) => update());
  }

  @override
  void dispose() {
    updateTimer.cancel();
    updateTask.cancel();
    super.dispose();
  }

  void update() {
    updateTask = CancelableOperation.fromFuture(Surfguru().getForecast());
    updateTask.then((value) => setState(() => conditions = value));
  }
}
