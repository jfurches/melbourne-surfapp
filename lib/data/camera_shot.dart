import '../services/beachcam.dart';

class CameraShot {
  final String name;
  final Uri url;
  final DateTime time;

  CameraShot(this.name, this.url, this.time);

  bool get isPanorama => name.contains("Panorama");
  bool get isAuto => name == "Auto";
  bool get isReal => url.toString().isNotEmpty;

  Future<CameraShot> resolve() async {
    if (isAuto) {
      var realShot =
          BeachCamService().pickBestShot(await BeachCamService().getShots());
      return CameraShot("Auto", realShot.url, realShot.time);
    }

    return this;
  }

  static CameraShot get none =>
      CameraShot("", Uri(), DateTime.fromMillisecondsSinceEpoch(0));
  static CameraShot get auto => CameraShot("Auto", Uri(), DateTime.now());

  @override
  bool operator ==(covariant CameraShot other) {
    if (isAuto && other.isAuto) {
      return true;
    }

    return name == other.name && time == other.time;
  }

  @override
  int get hashCode => name.hashCode ^ time.hashCode;

  @override
  String toString() => 'CameraShot{name: $name, time: $time}';
}
