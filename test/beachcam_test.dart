import 'package:surfapp/services/beachcam.dart';
import 'package:test/test.dart';

void main() {
  test('Test beachcam url', () async {
    var url = await BeachCamService().pickBestShot();
    expect(url, isNotNull);
  });
}
