import 'package:surfapp/services/beachcam.dart';
import 'package:test/test.dart';

void main() {
  test('Test fetching shots', () async {
    // Initially we have no data, so the camera service
    // should refresh
    expect(BeachCamService().shouldRefresh(), isTrue);

    // Fetch the camera shots
    var shots = await BeachCamService().fetchShots();
    expect(shots, isNotEmpty);

    // We can test for all the names here because the service
    // doesn't filter based on how recent the shot is. That's
    // handled by the camera controller.
    var expectedNames = <String>{
      "North Jetty",
      "North Zoom",
      "South Jetty",
      "West Shot",
      "North Panorama",
      "South Panorama"
    };

    var actualNames = shots.map((shot) => shot.name).toSet();
    expect(actualNames, expectedNames);

    // Since it's up to date, future calls for a little while
    // should use the cached values.
    expect(BeachCamService().shouldRefresh(), isFalse);
  });
}
