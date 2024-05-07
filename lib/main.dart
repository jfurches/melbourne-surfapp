import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

import 'components/beachcam/background.dart';
import 'components/ui/ambient.dart';
import 'components/ui/forecast.dart';
import 'data/camera_controller.dart';
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
    var isNight = now.hour < 7 || now.hour >= 20;

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
  late final CameraController cameraController;

  var uiState = UiState.ambient;
  CancelableOperation<UiState> uiTransitionTask =
      CancelableOperation.fromValue(UiState.ambient);

  @override
  void initState() {
    super.initState();
    cameraController = CameraController();
  }

  void updateUiState(UiState newState) {
    if (newState != uiState) {
      uiTransitionTask.cancel();
      setState(() => uiState = newState);

      // Schedule the transition to the next state
      var futureState = newState.ambientTransition();
      uiTransitionTask = CancelableOperation.fromFuture(futureState);
      uiTransitionTask.value.then((value) => updateUiState(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => updateUiState(uiState.nextOnTouch()),
        child: Stack(
          children: [
            BeachCamBackground(
              controller: cameraController,
              touchEnabled: uiState.isTouchEnabled,
            ),
            // Forecast UI
            WrappedUi(
              currentState: uiState,
              visibleState: UiState.forecast,
              child: const ForecastUi(),
            ),
            // Ambient UI
            WrappedUi(
              currentState: uiState,
              visibleState: UiState.ambient,
              child: Container(
                padding: const EdgeInsets.all(50.0),
                child: AmbientUi(cameraController: cameraController),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    uiTransitionTask.cancel();
    cameraController.dispose();
    super.dispose();
  }
}

/// Enum representing the state of the user interface
enum UiState {
  /// Show the passive UI
  ambient,

  /// Show upcoming beach forecasts
  forecast,

  /// Hide UI for maximum visibility of the background
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

class WrappedUi extends StatelessWidget {
  final UiState visibleState;
  final UiState currentState;
  final Widget? child;

  const WrappedUi(
      {super.key,
      required this.visibleState,
      required this.currentState,
      this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: currentState != visibleState,
      child: AnimatedOpacity(
        opacity: currentState == visibleState ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: child,
      ),
    );
  }
}
