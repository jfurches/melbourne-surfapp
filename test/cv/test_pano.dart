import 'package:opencv_dart/opencv_dart.dart' as cv;
import 'package:test/test.dart';

void main() {
  test('Find panorama boundaries', () {
    var panoImg = cv.imread("assets/sb_pano.jpg");
    var gradient = cv.sobel(panoImg, 1, 2, 2);
    cv.imwrite("gradient.jpg", gradient);
  });
}
