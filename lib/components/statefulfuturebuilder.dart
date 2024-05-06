import 'package:async/async.dart';
import 'package:flutter/widgets.dart';

typedef AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, AsyncSnapshot<T> snapshot, T? oldData);

class StatefulFutureBuilder<T> extends StatefulWidget {
  final Future<T>? initialFuture;
  final AsyncWidgetBuilder<T> builder;

  const StatefulFutureBuilder({
    super.key,
    this.initialFuture,
    required this.builder,
  });

  @override
  State<StatefulFutureBuilder<T>> createState() =>
      _StatefulFutureBuilderState<T>();
}

class _StatefulFutureBuilderState<T> extends State<StatefulFutureBuilder<T>> {
  late AsyncSnapshot<T> snapshot;
  late CancelableOperation<void> operation;
  T? oldData;

  @override
  void initState() {
    super.initState();
    snapshot = const AsyncSnapshot.waiting();
    if (widget.initialFuture != null) {
      _listenToFuture(widget.initialFuture!);
    }
  }

  void _listenToFuture(Future<T> future) {
    var toCancelFuture = future.then(
        (value) => setState(() {
              snapshot = AsyncSnapshot<T>.withData(ConnectionState.done, value);
              oldData = value;
            }),
        onError: (error) => setState(() {
              snapshot =
                  AsyncSnapshot<T>.withError(ConnectionState.done, error);
              oldData = null;
            }));

    operation = CancelableOperation.fromFuture(toCancelFuture);
  }

  @override
  void didUpdateWidget(covariant StatefulFutureBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialFuture != oldWidget.initialFuture) {
      if (widget.initialFuture != null) {
        _listenToFuture(widget.initialFuture!);
      } else {
        // Reset to waiting state if no new future provided
        setState(() => snapshot = const AsyncSnapshot.waiting());
      }
    }
  }

  @override
  void dispose() {
    operation.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, snapshot, oldData);
  }
}
