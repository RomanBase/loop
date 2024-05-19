import 'package:flutter_control/control.dart';

extension _Args on CoreContext {
  dynamic get progress => value<double>(key: 'progress', value: 0.0, stateNotifier: true);
}

class InitPage extends SingleControlWidget<InitLoaderControl> {
  const InitPage({super.key});

  @override
  void onInit(Map args, CoreContext context) {
    super.onInit(args, context);

    context.register(BroadcastProvider.subscribe<double>('asset_loader', (value) {
      context.progress.value = value;
    }));
  }

  @override
  Widget build(CoreElement context, InitLoaderControl control) {
    return Scaffold(
      body: Container(
        color: Colors.lightBlueAccent,
        child: Center(
          child: Text(
            '${context.progress.value * 100.0}%',
          ),
        ),
      ),
    );
  }
}
