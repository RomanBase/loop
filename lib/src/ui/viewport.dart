part of '../../loop.dart';

class SceneViewport extends StatefulWidget {
  final double? width;
  final double? height;
  final double? ratio;
  final Widget child;

  const SceneViewport({
    super.key,
    this.width,
    this.height,
    this.ratio,
    required this.child,
  });

  static SceneViewportState? of(BuildContext context) => context.findRootAncestorStateOfType<SceneViewportState>();

  @override
  State<StatefulWidget> createState() => SceneViewportState();
}

class SceneViewportState extends State<SceneViewport> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class SceneViewportBuilder extends StatelessWidget {
  final Loop scene;
  final double? width;
  final double? height;
  final double? ratio;

  const SceneViewportBuilder({
    super.key,
    required this.scene,
    this.width,
    this.height,
    this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) => CustomPaint(
        painter: SceneViewportPainter(
          widget: this,
        ),
        size: (constrains.hasBoundedWidth && constrains.hasBoundedHeight) ? Size(constrains.maxWidth, constrains.maxHeight) : Size.zero,
      ),
    );
  }
}

class SceneViewportPainter extends CustomPainter {
  final SceneViewportBuilder widget;

  const SceneViewportPainter({
    required this.widget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    widget.scene.prepareViewport(
      size,
      requiredWidth: widget.width,
      requiredHeight: widget.height,
    );

    widget.scene.render(canvas, Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}