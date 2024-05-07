class CameraShot {
  final String name;
  final Uri url;
  final DateTime time;

  CameraShot(this.name, this.url, this.time);

  bool get isPanorama => name.contains("Panorama");
  bool get isAuto => name == "Auto";
  bool get isReal => url.toString().isNotEmpty;

  static CameraShot get none =>
      CameraShot("", Uri(), DateTime.fromMillisecondsSinceEpoch(0));
  static CameraShot get auto => CameraShot("Auto", Uri(), DateTime.now());

  @override
  bool operator ==(covariant CameraShot other) {
    // Two Auto shots should only be equal if they're both virtual,
    // as otherwise the url field could have changed.
    if ((isAuto && other.isAuto) && !(isReal || other.isReal)) {
      return true;
    }

    return name == other.name && time == other.time;
  }

  @override
  int get hashCode => name.hashCode ^ time.hashCode;

  @override
  String toString() => 'CameraShot{name: $name, time: $time}';
}
