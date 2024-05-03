part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;

  bool checkBounds(Rect rect) => true;

  void render(Canvas canvas, Rect rect) {
    final rect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
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
    component.render(canvas, canvas.getDestinationClipBounds());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
