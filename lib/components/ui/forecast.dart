import 'package:flutter/widgets.dart';

import 'forecast/forecast_card_grid.dart';

class ForecastUi extends StatelessWidget {
  const ForecastUi({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 300,
        width: 800,
        child: ForecastCardGrid(),
      ),
    );
  }
}
