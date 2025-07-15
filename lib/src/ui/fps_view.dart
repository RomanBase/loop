part of '../../loop.dart';

class FpsView extends StatelessWidget {
  final ControlLoop? control;
  final Loop? loop;
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
    final ticker = control ?? ControlLoop.global();

    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: () {
          for (final element in ticker.children) {
            if (element is Loop) {
              final box = element.findComponents<BBoxRenderComponent>();
              if (box.isEmpty) {
                element.attach(BBoxRenderComponent()..color = Colors.red.withOpacity(0.35));
                if (element.findComponent<LoopCollisionComponent>() != null) {
                  element.attach(
                    BBoxRenderComponent<LoopCollisionComponent>()
                      ..color = Colors.green
                      ..componentList = () {
                        return [
                          ...(ticker is LoopCollisionSubsystem) ? (ticker as LoopCollisionSubsystem).getCollisionTree() : [],
                          ...(loop is LoopCollisionSubsystem) ? (loop as LoopCollisionSubsystem).getCollisionTree() : [],
                        ];
                      }
                      ..componentSize = (component) => component.collisionBounds.size.reverse(component.worldMatrix.scaleX2D, component.worldMatrix.scaleY2D),
                  );
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
