import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/playground/viewport_view.dart';
import 'package:loop_editor/resources/theme.dart';

final r = Random();

extension _PlaygroundComponent on CoreContext {
  SceneComponent get c1 => use(key: 'c1', value: () => SceneComponent())!;

  SceneComponent get c2 => use(key: 'c2', value: () => SceneComponent())!;

  LoopScene get scene => use(
      key: 'scene',
      value: () {
        final loop = LoopScene();
        loop.timeDilation = 0.25;

        loop.add(Sprite(asset: Asset.get('placeholder'))
          ..zIndex = -1
          ..size = const Size(64.0, 64.0)
          ..translate(const Offset(240.0, 240.0))
          ..updateDeltaLoopBehavior(LoopBehavior.loop));

        loop.add(Sprite(asset: Asset.get('placeholder'))
          ..size = const Size(32.0, 32.0)
          ..transform.origin = const Offset(16.0, 16.0)
          ..translate(const Offset(240.0, 240.0), begin: const Offset(240.0, 120.0))
          ..rotate(360.0)
          ..scale(const Scale.of(3.0))
          ..attach(Sprite(asset: Asset.get('placeholder'))
            ..size = const Size(24.0, 24.0)
            ..transform.origin = const Offset(12.0, 12.0)
            ..transform.position = const Offset(28.0, 0.0)
            ..attach(Sprite(asset: Asset.get('placeholder'))
              ..transform.origin = const Offset(8.0, 8.0)
              ..size = const Size(16.0, 16.0)
              ..transform.position = const Offset(20.0, 0.0)
              ..translate(const Offset(64.0, 0.0)).setLoopBehavior(LoopBehavior.reverseLoop)
              ..scale(const Scale.of(2.0)).setLoopBehavior(LoopBehavior.reverseLoop)
              ..rotate(360).setLoopBehavior(LoopBehavior.reverseLoop)))
          ..updateDeltaLoopBehavior(LoopBehavior.reverseLoop));

        loop.add(Sprite(
          asset: Asset.get('mc'),
          actions: {
            'fire': const SpriteAction(
              count: 24,
              axis: Axis.vertical,
              blend: Curves.easeInQuad,
              fps: 8,
            ),
          },
        )
          ..transform.position = const Offset(320.0, 320.0)
          ..translate(const Offset(320.0, 280.0)).setLoopBehavior(LoopBehavior.loop)
          ..scale(const Scale.of(2.0)).setLoopBehavior(LoopBehavior.loop));

        return loop;
      })!;

  SceneComponent operator [](dynamic key) => use(
      key: key,
      value: () {
        final c = SceneComponent();

        final d = Duration(milliseconds: 1000 + r.nextInt(9000));
        final x = UITheme.device.width * r.nextDouble();
        final s = 1.0 + r.nextInt(2);

        c.transform.origin = const Offset(32.0, 32.0);
        c.translate(Offset(x, 0.0), begin: Offset(x, UITheme.device.height), duration: d);
        c.rotate(r.nextDouble() * 720.0, duration: d);
        c.scale(Scale.of(s), duration: d);
        c.color(Color(r.nextInt(4294967295)), begin: Color(r.nextInt(4294967295)), duration: d);

        c.updateDeltaLoopBehavior(LoopBehavior.loop);

        return c;
      })!;
}

class Playground extends ControlWidget {
  const Playground({super.key});

  @override
  void onInit(Map args, CoreContext context) {
    super.onInit(args, context);

    context.c1
      ..translate(Offset(320.0, UITheme.device.height * 0.5), duration: const Duration(seconds: 2)).curve = Curves.easeOutQuad
      ..translate(Offset(120.0, UITheme.device.height * 0.5)).curve = Curves.easeInCubic
      ..translate(Offset(120.0, UITheme.device.height * 0.65))
      ..scale(const Scale(4.0, 2.0))
      ..scale(const Scale(3.0, 3.0))
      ..scale(const Scale(1.0, 1.0));

    context.c1.getComponent<DeltaPosition>()?.setReverse(true);
    context.c1.getComponent<DeltaPosition>()?.setLoopBehavior(LoopBehavior.reverseLoop);
    context.c1.getComponent<DeltaScale>()?.setLoopBehavior(LoopBehavior.loop);

    context.c2
      ..transform.origin = const Offset(24.0, 24.0)
      ..translate(Offset(UITheme.device.width * 0.5, UITheme.device.height * 0.25))
      ..translate(Offset(UITheme.device.width * 0.75, UITheme.device.height * 0.25)).until(
        postpone: WaitCondition(duration: const Duration(milliseconds: 1000)),
        hold: CycleCondition(cycles: 2),
        loopHold: LoopBehavior.reverseLoop,
      )
      ..translate(Offset(UITheme.device.width * 0.85, UITheme.device.height * 0.65))
      ..scale(const Scale(3.0, 2.0))
      ..scale(const Scale(1.5, 1.5))
      ..scale(const Scale(0.5, 1.0))
      ..opacity(0.25)
      ..opacity(0.25)
      ..opacity(1.0)
      ..color(Colors.lightBlueAccent, begin: Colors.black)
      ..color(Colors.greenAccent)
      ..color(Colors.orangeAccent)
      ..rotate(360.0);

    context.c2.updateDeltaLoopBehavior(LoopBehavior.reverseLoop);
    context.c2.getComponent<DeltaRotation>()?.setLoopBehavior(LoopBehavior.loop);
  }

  @override
  Widget build(CoreElement context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bbox = context.use<BBoxRenderComponent>(value: () => BBoxRenderComponent()..zIndex = 100)!;

          if (context.scene.items.contains(bbox)) {
            context.scene.remove(bbox);
          } else {
            context.scene.add(bbox);
          }
        },
        child: const Icon(Icons.border_all_rounded),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(64.0),
            child: Scene(
              loop: context.scene,
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
          ),
          const FpsView(
            alignment: Alignment.bottomLeft,
          ),
          ViewportView(
            control: context.scene,
          ),
        ],
      ),
    );
  }
}

class PerformanceTest extends ControlWidget {
  final bool builder;
  final int count;

  const PerformanceTest({
    super.key,
    this.builder = false,
    this.count = 100,
  });

  @override
  Widget build(CoreElement context) {
    if (builder) {
      return Scene.builder(
        builders: List.generate(
            count,
            (index) => (_, dt) {
                  context[index].tick(dt);

                  return Transform(
                    transform: context[index].transform.matrix,
                    origin: context[index].transform.origin,
                    child: Container(
                      width: 64.0,
                      height: 64.0,
                      color: context[index].deltaColor,
                      child: Center(
                        child: Image.asset(
                          'assets/placeholder.png',
                          width: 32.0,
                          height: 32.0,
                        ),
                      ),
                    ),
                  );
                }),
      );
    }

    return Scene(
      children: List.generate(
        count,
        (index) => SceneComponentBuilder(
          component: context[index],
          builder: (_, dt) => Container(
            width: 24.0,
            height: 24.0,
            color: context[index].deltaColor,
            child: Center(
              child: Text('$index'),
            ),
          ),
        ),
      ),
    );
  }
}
