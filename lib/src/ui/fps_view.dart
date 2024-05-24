part of '../../loop.dart';

class FpsView extends StatelessWidget {
  final ControlLoop? control;
  final LoopScene? loop;
  final Alignment alignment;
  final TextStyle? style;

  const FpsView({
    super.key,
    this.control,
    this.loop,
    this.alignment = Alignment.bottomRight,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final ticker = control ?? ControlLoop.main();

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          for (final element in ticker.children) {
            if (element is LoopScene) {
              final box = element.findComponents<BBoxRenderComponent>();
              if (box.isEmpty) {
                element.attach(BBoxRenderComponent()..color = Colors.red.withOpacity(0.35));
                if (ticker is LoopCollisionSubsystem || loop is LoopCollisionSubsystem) {
                  element.attach(BBoxRenderComponent<LoopCollisionComponent>()
                    ..color = Colors.green
                    ..componentSize = (component) => component.bounds.size);
                }
              } else {
                for (final element in box) {
                  element.removeFromParent();
                }
              }
            }
          }
        },
        child: SizedBox(
          width: 32.0,
          height: 32.0,
          child: Scene.builder(
            control: ticker,
            loop: loop,
            builders: [
              (context, dt) => Center(
                    child: Container(
                      color: ticker.fps < 30 ? Colors.red : Colors.white30,
                      child: Text(
                        '${ticker.fps}',
                        style: style,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
