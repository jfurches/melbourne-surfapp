import 'dart:async';

import 'package:surfapp/data/camera_controller.dart';
import 'package:surfapp/data/camera_shot.dart';
import 'package:test/test.dart';

void main() {
  group('New active shot notifications', () {
    test('Test selection update', () async {
      var completer = Completer<CameraShot>();
      var controller = CameraController();

      // Initially it should be set to auto
      expect(controller.activeShot, CameraShot.auto);

      // Subscribe to updates
      controller.onActiveShotChange((shot) {
        completer.complete(shot);
      });

      // Set a new one
      var northZoomShot = CameraShot(
        "North Zoom",
        Uri.parse(
            "https://www.sebastianinletcam.com/pics/s24/apr3024t/y082004f.jpg"),
        DateTime.now(),
      );
      controller.activeShot = northZoomShot;

      // It should be the one we put in
      expect(await completer.future, northZoomShot);
    });
    test('Test updating auto', () async {
      var completer = Completer<CameraShot>();
      var controller = CameraController();

      // Simulate having an auto shot
      var autoShot = CameraShot(
        "Auto",
        Uri.parse(
            "https://www.sebastianinletcam.com/pics/s24/apr3024t/y082004f.jpg"),
        DateTime.now(),
      );
      controller.activeShot = autoShot;

      // Expect that the controller is set to auto
      // but has a real url ready
      expect(controller.resolvedShot.isAuto, isTrue);
      expect(controller.resolvedShot.isReal, isTrue);

      // Subscribe to updates
      controller.onActiveShotChange((shot) {
        completer.complete(shot);
      });

      // Simulate an updated version of the auto shot,
      // with a new url
      var newShot = CameraShot(
        "Auto",
        Uri.parse(
            "https://www.sebastianinletcam.com/pics/s20/apr0824v/y082319o.jpg"),
        DateTime.now(),
      );

      controller.activeShot = newShot;

      // We should get the notification even though both are "auto"
      expect(await completer.future, newShot);
    });
  });
  test('Test automatically refreshes', () async {
    var completer = Completer<CameraShot>();
    var controller = CameraController();

    // Subscribe to updates
    controller.onActiveShotChange((shot) {
      completer.complete(shot);
    });

    // The constructor of CameraController has made an
    // async call to refresh(). Wait for it to complete.

    // Depending on the current time, there may only
    // be one shot available, so we can't guarantee
    // isAuto = true.
    var shot = await completer.future;
    expect(shot.isReal, isTrue);
  });
}
