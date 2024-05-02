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
      child: Scene.builder(
        control: control,
        loop: loop,
        builders: [
          (context, dt) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${ticker.fps}',
                  style: style,
                ),
              ),
        ],
      ),
    );
  }
}
