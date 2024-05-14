part of '../../loop.dart';

const _targetFrameDelta = 1.0 / 60.0;

class ControlLoop with ObservableLoop {
  late final Ticker _ticker;
  final bool lazyRun;

  double deltaTime = _targetFrameDelta;

  Duration _lastTick = Duration.zero;

  int get fps => 1.0 ~/ (deltaTime > 0.0 ? deltaTime : 0.1);

  bool get running => _ticker.isTicking;

  ControlLoop({this.lazyRun = true}) {
    _ticker = Ticker(_tick);
  }

  factory ControlLoop.main() {
    final instance = Control.get<ControlLoop>();

    if (instance != null) {
      return instance;
    }

    return ControlLoop().._register();
  }

  void _register() {
    Control.set<ControlLoop>(value: this);
  }

  void _tick(Duration elapsed) {
    deltaTime = (elapsed - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = elapsed;

    setValue(deltaTime);
  }

  void start() {
    if (running) {
      return;
    }

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

    _ticker.dispose();
  }
}

/// Base tick component.
mixin LoopComponent {
  bool active = true;

  void tick(double dt);
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
  void cancel(ControlSubscription<double> subscription) => _observable.cancel(subscription);

  @override
  ObservableValue<U> cast<U>() => this as ObservableValue<U>;

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
  bool active = true;

  @override
  ControlSubscription subscribe(VoidCallback action, {dynamic args}) => _observable.subscribe(
        (_) => action.call(),
        current: false,
        args: args,
      );

  @override
  void cancel(ControlSubscription subscription) => _observable.cancel(subscription);

  @override
  void notify() {
    if (_observable.subCount > 0) {
      _observable.notify();
    }
  }

  @override
  void dispose() {
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

    _control = loop ?? ControlLoop.main();
    _sub = _control!.subscribe(tick);
  }

  void unmount() {
    _sub?.dispose();
    _sub = null;
    _control = null;
  }

  @override
  void dispose() {
    unmount();
  }
}
