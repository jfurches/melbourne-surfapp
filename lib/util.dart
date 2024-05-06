String displayTime(DateTime t) {
  var afternoon = t.hour ~/ 12 == 1;
  var time = t.hour % 12;

  return "$time${afternoon ? 'p' : 'a'}";
}

Iterable<T> interleave<T>(Iterable<T> a, T b) {
  var n = a.length;
  return Iterable.generate(
      2 * n - 1, (i) => i % 2 == 0 ? a.elementAt(i ~/ 2) : b);
}

extension Interleaving<T> on Iterable<T> {
  Iterable<T> interleaving(T b) => interleave(this, b);
}
