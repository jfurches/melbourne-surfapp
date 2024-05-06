import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'cards/nowcard.dart';
import 'components/beachcam_background.dart';
import 'components/forecast_widget.dart';
import 'components/shot_select_widget.dart';
import 'services/beachcam.dart';
import 'services/surfguru.dart';
import 'themes.dart';

void main() {
  runApp(const SurfApp());
}

class SurfApp extends StatefulWidget {
  const SurfApp({super.key});

  @override
  State<SurfApp> createState() => SurfAppState();
}

class SurfAppState extends State<SurfApp> {
  ThemeData currentTheme = Themes.lightTheme;
  late Timer _timer;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SurfApp',
      theme: currentTheme,
      home: const SurfPage(),
    );
  }

  void updateTheme() {
    var now = DateTime.now();
    var isNight = now.hour < 7 || now.hour >= 21;

    var newtheme = isNight ? Themes.darkTheme : Themes.lightTheme;
    if (newtheme != currentTheme) {
      setState(() {
        currentTheme = newtheme;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    updateTheme();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      updateTheme();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

class SurfPage extends StatefulWidget {
  const SurfPage({super.key});

  @override
  State<SurfPage> createState() => _SurfPageState();
}

class _SurfPageState extends State<SurfPage> {
  var availableCameraShots = Future.value(<CameraShot>[]);

  var selectedCameraShot = CameraShot.auto;
  var cameraShotNotifier = ValueNotifier<CameraShot>(CameraShot.auto);
  var forecastFuture = Surfguru().getForecast();
  var conditionsFuture = Surfguru().getCurrentConditions();

  var uiState = UiState.ambient;
  CancelableOperation<UiState> uiTransitionTask =
      CancelableOperation.fromValue(UiState.ambient);
  late Timer _timer;

  _SurfPageState();

  @override
  void initState() {
    super.initState();
    _refreshInfo();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _refreshInfo();
    });

    // If the user selects a new camera shot, update it here so
    // it can get passed to the background widget
    cameraShotNotifier.addListener(() {
      setState(() => selectedCameraShot = cameraShotNotifier.value);
    });
  }

  /// Refreshes all information from surfguru and beachcam
  /// Todo: Consider making the individual widgets refresh themselves
  void _refreshInfo() {
    BeachCamService().getShot(selectedCameraShot.name).then((value) {
      setState(() => selectedCameraShot = value);
    });

    setState(() {
      availableCameraShots = BeachCamService().getShots();
      forecastFuture = Surfguru().getForecast();
      conditionsFuture = Surfguru().getCurrentConditions();
    });
  }

  void _onTouch() {
    updateUiState(uiState.nextOnTouch());
  }

  void updateUiState(UiState newState) {
    if (newState != uiState) {
      uiTransitionTask.cancel();
      setState(() => uiState = newState);
      if (newState != UiState.ambient) {
        var futureState = newState.ambientTransition();
        uiTransitionTask = CancelableOperation.fromFuture(futureState);
        uiTransitionTask.value.then((value) => updateUiState(value));
      } else {
        uiTransitionTask = CancelableOperation.fromValue(UiState.ambient);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _onTouch,
        child: BeachCamBackground(
          shot: selectedCameraShot,
          touchEnabled: uiState.isTouchEnabled,
          child: Stack(
            children: [
              // Forecast UI
              AnimatedOpacity(
                opacity: uiState == UiState.forecast ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: BeachForecastWidgetWrapper(future: forecastFuture),
              ),
              // Ambient UI
              Container(
                padding: const EdgeInsets.all(50.0),
                child: AnimatedOpacity(
                  opacity: uiState == UiState.ambient ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Stack(
                    children: [
                      // Current conditions card
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: NowCardWrapper(future: conditionsFuture),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: CameraShotSelectionWrapper(
                          future: availableCameraShots,
                          notifier: cameraShotNotifier,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    uiTransitionTask.cancel();
    _timer.cancel();
    cameraShotNotifier.dispose();
    super.dispose();
  }
}

enum UiState {
  ambient,
  forecast,
  blank;

  /// Gives the next state that should be shown after a touch
  UiState nextOnTouch() {
    // ambient --> forecast <--> blank
    switch (this) {
      case UiState.ambient:
        return UiState.forecast;
      case UiState.forecast:
        return UiState.blank;
      case UiState.blank:
        return UiState.forecast;
    }
  }

  /// Gives the ambient transition assuming no user interaction
  Future<UiState> ambientTransition() async {
    switch (this) {
      // Never transition from ambient
      case UiState.ambient:
        return UiState.ambient;

      // Transition from forecasting to blank after 1 minute
      case UiState.forecast:
        await Future.delayed(const Duration(minutes: 1));
        return UiState.blank;

      // Use blank as a pretty transition to ambient
      case UiState.blank:
        await Future.delayed(const Duration(seconds: 5));
        return UiState.ambient;
    }
  }

  bool get isTouchEnabled {
    switch (this) {
      case UiState.ambient:
      case UiState.blank:
        return true;
      case UiState.forecast:
        return false;
    }
  }
}
