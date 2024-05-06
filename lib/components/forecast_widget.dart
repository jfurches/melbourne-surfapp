import 'package:flutter/material.dart';

import '../cards/surf_card.dart';
import '../cards/wind_card.dart';
import '../data/beachforecast.dart';

class BeachForecastWidget extends StatelessWidget {
  final BeachForecast conditions;

  const BeachForecastWidget({super.key, required this.conditions});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 300,
        width: 800,
        child: GridView.extent(
          // mainAxisSpacing: 10,
          // crossAxisSpacing: 10,
          maxCrossAxisExtent: 600,
          padding: EdgeInsets.zero,
          childAspectRatio: 4 / 3,
          children: [
            SurfCard(beachConditions: conditions),
            WindCard(beachConditions: conditions),
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
        ),
      ),
    );
  }
}

class BeachForecastWidgetWrapper extends StatelessWidget {
  final Future<BeachForecast> future;

  const BeachForecastWidgetWrapper({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BeachForecast>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return BeachForecastWidget(conditions: snapshot.data!);
        }

        return const CircularProgressIndicator();
      },
    );
  }
}
