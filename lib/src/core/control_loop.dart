part of '../../loop.dart';

const _targetFrameDelta = 1.0 / 60.0;

class ControlLoop with ObservableLoop {
  late final Ticker _ticker;
  final bool lazyRun;

  final children = <LoopComponent>{};

  double deltaTime = _targetFrameDelta;

  Duration _lastTick = Duration.zero;

  int get fps => 1.0 ~/ (deltaTime > 0.0 ? deltaTime : 0.1);

  bool get running => _ticker.isTicking;

  ControlLoop({this.lazyRun = true}) {
    _ticker = Ticker(_tick);
  }

  static ControlLoop global() => Control.use<ControlLoop>(value: () => ControlLoop());

  void _tick(Duration elapsed) {
    final tickTime = elapsed - _lastTick;

    if (tickTime.isNegative) {
      _lastTick = Duration.zero;
      deltaTime = 0.0;
    } else {
      deltaTime = tickTime.inMicroseconds / Duration.microsecondsPerSecond;
      _lastTick = elapsed;
    }

    setValue(deltaTime);
    onTick(value);
  }

  @override
  void onTick(double dt) {}

  void start() {
    if (running) {
      return;
    }

    _lastTick = Duration.zero;
    _ticker.start();
  }

  void stop() {
    if (!running) {
      return;
    }

    _ticker.stop();
  }

  void _notifyLazyRun() {
    if (_observable.subCount > 0) {
      start();
    } else {
      stop();
    }
  }

  @override
  ControlSubscription<double> subscribe(ValueCallback<double> action, {bool current = true, args}) {
    final sub = super.subscribe(action, current: current, args: args);

    _notifyLazyRun();

    return sub;
  }

  @override
  void cancel(ControlSubscription<double> subscription) {
    super.cancel(subscription);

    _notifyLazyRun();
  }

  @override
  void dispose() {
    super.dispose();

    stop();
    _ticker.dispose();
  }
}

/// 'Main' Loop dispatcher.
/// Any Object can subscribe to be notified about deltaTime.
mixin ObservableLoop implements ObservableValue<double>, ObservableNotifier, Disposable {
  final _observable = ControlObservable<double>(0.0);

  double timeDilation = 1.0;

  @override
  dynamic internalData;

  @override
  double get value => _observable.value;

  void onTick(double dt);

  void setValue(double value, {bool notify = true}) => _observable.setValue(
        value * timeDilation,
        notify: notify,
        forceNotify: notify,
      );

  @override
  ControlSubscription<double> subscribe(ValueCallback<double> action, {bool current = true, dynamic args}) => _observable.subscribe(
        action,
        current: current,
        args: args,
      );

  @override
  ControlSubscription<double> listen(VoidCallback action) => _observable.listen(action);

  @override
  void cancel(ControlSubscription<double> subscription) => _observable.cancel(subscription);

  @override
  void notify() => _observable.notify();

  @override
  void dispose() {
    _observable.dispose();
  }
}

/// 'Component' Loop dispatcher.
mixin ObservableLoopComponent implements LoopComponent, ObservableChannel, Disposable {
  final _observable = ControlObservable.empty();

  @override
  dynamic internalData;

  @override
  late String tag = '$runtimeType';

  @override
  bool active = true;

  @override
  ControlSubscription subscribe(VoidCallback action, {bool current = false, dynamic args}) => _observable.subscribe(
        (_) => action.call(),
        current: current,
        args: args,
      );

  @override
  ControlSubscription<void> listen(VoidCallback action) => _observable.listen(action);

  @override
  void cancel(ControlSubscription subscription) => _observable.cancel(subscription);

  void notify() {
    if (_observable.subCount > 0) {
      _observable.notify();
    }
  }

  @override
  void destroy() {
    dispose();
  }

  @override
  void dispose() {
    active = false;
    _observable.dispose();
  }
}

/// 'Leaf' observer
mixin LoopLeaf on LoopComponent implements Disposable {
  ControlLoop? _control;
  ControlSubscription? _sub;

  ControlLoop get control => _control!;

  bool get isMounted => _sub?.isValid ?? false;

  void mount([ControlLoop? loop]) {
    assert(!isMounted, 'Can\'t use one Scene for multiple Loops');

    _control = loop ?? ControlLoop.global();
    _sub = _control?.subscribe(tick);
    _control?.children.add(this);
  }

  void unmount() {
    _control?.children.remove(this);
    _sub?.dispose();
    _sub = null;
    _control = null;
  }

  @override
  void dispose() {
    unmount();
  }
}
