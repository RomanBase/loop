import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';

class Mouse extends SceneComponent with RenderComponent, PointerComponent {
  Mouse() {
    zIndex = 999;
    size = const Size.square(16.0);
  }

  @override
  void render(Canvas canvas, Rect rect) {
    renderComponent(canvas, this, (dst) {
      canvas.drawCircle(dst.center, dst.width * 0.5, Paint()..color = pointer.isDown ? Colors.blue : Colors.black);

      final text = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )
        ..text = TextSpan(
          text: '${transform.position.dx.toInt()}, ${transform.position.dy.toInt()}',
          style: const TextStyle(
            letterSpacing: 0.0,
            fontSize: 10.0,
            color: Colors.blue,
          ),
        )
        ..layout();

      text.paint(canvas, Offset(dst.center.dx - text.width * 0.5, dst.bottom + 12.0));
    });
  }

  @override
  bool onPointerDown(PointerEvent event) {
    pointer.isDown = true;
    pointer.down?.call(event);
    return false;
  }

  @override
  bool onPointerMove(PointerEvent event) {
    transform.position = event.localPosition + getLoop()!.viewport.position;
    pointer.move?.call(event);
    return false;
  }

  @override
  bool onPointerUp(PointerEvent event) {
    pointer.isDown = false;
    pointer.up?.call(event);
    return false;
  }

  @override
  bool onPointerCancel(PointerEvent event) {
    pointer.isDown = false;
    pointer.cancel?.call(event);
    return false;
  }

  @override
  bool onPointerHover(PointerEvent event) {
    transform.position = event.localPosition + getLoop()!.viewport.position;
    pointer.hover?.call(event);
    return false;
  }
}