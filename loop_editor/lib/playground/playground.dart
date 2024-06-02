import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/playground/drag_sprite.dart';
import 'package:loop_editor/playground/mouse.dart';
import 'package:loop_editor/playground/viewport_view.dart';
import 'package:loop_editor/resources/theme.dart';

final r = Random();

extension _PlaygroundComponent on CoreContext {
  SceneComponent get c1 => use(key: 'c1', value: () => SceneComponent())!;

  SceneComponent get c2 => use(key: 'c2', value: () => SceneComponent())!;

  Loop get scene => use(
      key: 'scene',
      value: () {
        final loop = Loop();
        loop.timeDilation = 0.25;

        loop.attach(Sprite(asset: Asset.get('placeholder'))
          ..zIndex = -1
          ..size = const Size(64.0, 64.0)
          ..transform.origin = Offset.zero
          ..applyTranslateCurve(const Offset(240.0, 240.0), const Offset(240.0, 0.0))
          ..applyDeltaLoopBehavior(LoopBehavior.reverseLoop));

        loop.attach(Sprite(asset: Asset.get('placeholder'))
          ..tag = 'group_0'
          ..size = const Size(32.0, 32.0)
          ..applyTranslate(const Offset(240.0, 240.0), begin: const Offset(240.0, 120.0))
          ..applyRotate(360.0)
          ..applyScale(const Scale.of(3.0))
          ..attach(Sprite(asset: Asset.get('placeholder'))
            ..tag = 'group_1'
            ..size = const Size(24.0, 24.0)
            ..transform.position = const Offset(28.0, 0.0)
            ..attach(Sprite(asset: Asset.get('placeholder'))
              ..tag = 'group_2'
              ..size = const Size(16.0, 16.0)
              ..transform.position = const Offset(20.0, 0.0)
              ..applyTranslate(const Offset(64.0, 0.0)).setLoopBehavior(LoopBehavior.reverseLoop)
              ..applyScale(const Scale.of(2.0)).setLoopBehavior(LoopBehavior.reverseLoop)
              ..applyRotate(360).setLoopBehavior(LoopBehavior.reverseLoop)))
          ..applyDeltaLoopBehavior(LoopBehavior.reverseLoop));

        loop.attach(Sprite(
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
          ..tag = 'fire'
          ..transform.position = const Offset(320.0, 320.0)
          ..applyTranslate(const Offset(320.0, 280.0)).setLoopBehavior(LoopBehavior.loop)
          ..applyScale(const Scale.of(2.0)).setLoopBehavior(LoopBehavior.loop));

        loop.attach(DragSprite());

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
        c.applyTranslate(Offset(x, 0.0), begin: Offset(x, UITheme.device.height), duration: d);
        c.applyRotate(r.nextDouble() * 720.0, duration: d);
        c.applyScale(Scale.of(s), duration: d);
        c.applyColor(Color(r.nextInt(4294967295)), begin: Color(r.nextInt(4294967295)), duration: d);

        c.applyDeltaLoopBehavior(LoopBehavior.loop);

        return c;
      })!;
}

class Playground extends ControlWidget {
  const Playground({super.key});

  @override
  void onInit(Map args, CoreContext context) {
    super.onInit(args, context);

    context.c1
      ..applyTranslate(Offset(320.0, UITheme.device.height * 0.5), duration: const Duration(seconds: 2)).curve = Curves.easeOutQuad
      ..applyTranslate(Offset(120.0, UITheme.device.height * 0.5)).curve = Curves.easeInCubic
      ..applyTranslate(Offset(120.0, UITheme.device.height * 0.65))
      ..applyScale(const Scale(4.0, 2.0))
      ..applyScale(const Scale(3.0, 3.0))
      ..applyScale(const Scale(1.0, 1.0));

    context.c1.getComponent<DeltaPosition>()?.setReverse(true);
    context.c1.getComponent<DeltaPosition>()?.setLoopBehavior(LoopBehavior.reverseLoop);
    context.c1.getComponent<DeltaScale>()?.setLoopBehavior(LoopBehavior.loop);

    context.c2
      ..transform.origin = const Offset(24.0, 24.0)
      ..applyTranslate(Offset(UITheme.device.width * 0.5, UITheme.device.height * 0.25))
      ..applyTranslate(Offset(UITheme.device.width * 0.75, UITheme.device.height * 0.25)).until(
        postpone: WaitCondition(duration: const Duration(milliseconds: 1000)),
        hold: CycleCondition(cycles: 2),
        loopHold: LoopBehavior.reverseLoop,
      )
      ..applyTranslate(Offset(UITheme.device.width * 0.85, UITheme.device.height * 0.65))
      ..applyScale(const Scale(3.0, 2.0))
      ..applyScale(const Scale(1.5, 1.5))
      ..applyScale(const Scale(0.5, 1.0))
      ..applyOpacity(0.25)
      ..applyOpacity(0.25)
      ..applyOpacity(1.0)
      ..applyColor(Colors.lightBlueAccent, begin: Colors.black)
      ..applyColor(Colors.greenAccent)
      ..applyColor(Colors.orangeAccent)
      ..applyRotate(360.0);

    context.c2.applyDeltaLoopBehavior(LoopBehavior.reverseLoop);
    context.c2.getComponent<DeltaRotation>()?.setLoopBehavior(LoopBehavior.loop);
  }

  @override
  Widget build(CoreElement context) {
    return SceneViewport(
      width: 400.0,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final bbox = context.use<BBoxRenderComponent>(value: () => BBoxRenderComponent()..zIndex = 100)!;
            final mouse = context.scene.findComponent<Mouse>();

            if (mouse == null) {
              context.scene.attach(Mouse());
            } else {
              mouse.removeFromParent();
            }

            if (context.scene.items.contains(bbox)) {
              context.scene.detach(bbox);
            } else {
              context.scene.attach(bbox);
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
                      color: context.c2.getComponent<DeltaColor>()?.value,
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
                      color: context[index].getComponent<DeltaColor>()?.value,
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
            color: context[index].getComponent<DeltaColor>()?.value,
            child: Center(
              child: Text('$index'),
            ),
          ),
        ),
      ),
    );
  }
}
