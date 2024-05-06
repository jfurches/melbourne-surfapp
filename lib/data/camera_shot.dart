class CameraShot {
  final String name;
  final Uri url;
  final DateTime time;

  CameraShot(this.name, this.url, this.time);

  bool get isPanorama => name.contains("Panorama");
  bool get isAuto => name == "Auto";

  static CameraShot get none =>
      CameraShot("", Uri(), DateTime.fromMillisecondsSinceEpoch(0));
  static CameraShot get auto => CameraShot("Auto", Uri(), DateTime.now());

  @override
  String toString() => 'CameraShot{name: $name, time: $time}';
}
