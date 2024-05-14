part of '../../loop.dart';

class CanvasBuilder extends StatelessWidget {
  final RenderComponent component;

  const CanvasBuilder({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) => CustomPaint(
        painter: RenderPainter(
          component: component,
        ),
        size: (constrains.hasBoundedWidth && constrains.hasBoundedHeight) ? Size(constrains.maxWidth, constrains.maxHeight) : Size.zero,
      ),
    );
  }
}

class RenderPainter extends CustomPainter {
  final RenderComponent component;
  final Offset offset;

  RenderPainter({
    required this.component,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    component.size = size;
    component.render(canvas, offset & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
