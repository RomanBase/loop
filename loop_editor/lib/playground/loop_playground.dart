import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/resources/theme.dart';

extension _LoopPlaygroundComponent on CoreContext {
  SceneComponent get c1 => use(key: 'c1', value: () => SceneComponent())!;

  SceneComponent get c2 => use(key: 'c2', value: () => SceneComponent())!;
}

class LoopPlayground extends ControlWidget {
  const LoopPlayground({super.key});

  @override
  void onInit(Map args, CoreContext context) {
    super.onInit(args, context);

    context.c1
      ..translate(Offset(320.0, UITheme.device.height * 0.5), duration: const Duration(seconds: 2)).curve = Curves.easeOutQuad
      ..translate(Offset(120.0, UITheme.device.height * 0.5)).curve = Curves.easeInCubic
      ..translate(Offset(120.0, UITheme.device.height * 0.65))
      ..scale(const Offset(4.0, 2.0))
      ..scale(const Offset(3.0, 3.0))
      ..scale(const Offset(1.0, 1.0));

    context.c1.getTransform<DeltaPosition>()?.setReverse(true);
    context.c1.getTransform<DeltaPosition>()?.setLoopBehavior(LoopBehavior.reverseLoop);
    context.c1.getTransform<DeltaScale>()?.setLoopBehavior(LoopBehavior.loop);

    context.c2
      ..origin = const Offset(24.0, 24.0)
      ..translate(Offset(UITheme.device.width * 0.5, UITheme.device.height * 0.25), begin: Offset(UITheme.device.width * 0.75, 0.0))
      ..translate(Offset(UITheme.device.width * 0.75, UITheme.device.height * 0.25)).until(
        postpone: WaitCondition(duration: const Duration(milliseconds: 1000)),
        hold: CycleCondition(cycles: 2),
        loopHold: LoopBehavior.reverseLoop,
      )
      ..translate(Offset(UITheme.device.width * 0.85, UITheme.device.height * 0.65))
      ..scale(const Offset(3.0, 2.0))
      ..scale(const Offset(1.5, 1.5))
      ..scale(const Offset(0.5, 1.0))
      ..opacity(0.25)
      ..opacity(0.25)
      ..opacity(1.0)
      ..color(Colors.lightBlueAccent, begin: Colors.black)
      ..color(Colors.greenAccent)
      ..color(Colors.orangeAccent, begin: Colors.red)
      ..rotate(360.0);

    context.c2.updateLoopBehavior(LoopBehavior.reverseLoop);
    context.c2.getTransform<DeltaRotation>()?.setLoopBehavior(LoopBehavior.loop);
  }

  @override
  Widget build(CoreElement context) {
    return Scaffold(
      body: Stack(
        children: [
          Scene.builder(
            builders: [
              (_, dt) {
                //context.c1.tick(dt);
                return Transform(
                  transform: context.c1.transform.matrix,
                  child: Container(
                    width: 32.0,
                    height: 32.0,
                    color: Colors.red,
                  ),
                );
              },
            ],
          ),
          Scene(
            children: [
              SceneComponentBuilder(
                component: context.c2,
                builder: (_, dt) => Container(
                  width: 48.0,
                  height: 48.0,
                  color: context.c2.deltaColor,
                ),
              ),
            ],
          ),
          const FpsView(),
        ],
      ),
    );
  }
}
