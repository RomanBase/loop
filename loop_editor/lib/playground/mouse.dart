import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';

class Mouse extends SceneComponent with RenderComponent, PointerComponent {
  Mouse() {
    zIndex = 999;
    pointer.primary = true;

    size = const Size.square(32.0);
    unbounded = true;
  }

  @override
  Rect get screenBounds {
    final viewport = getLoop()!.viewport;
    final offset = (viewport.transformViewPosition(transform.position) + viewport.position) * viewport.scale;

    return Rect.fromLTWH(
      offset.x + viewport.screenSize.width * 0.5 - size.width * 0.5,
      offset.y + viewport.screenSize.height * 0.5 - size.height * 0.5,
      size.width,
      size.height,
    );
  }

  @override
  void render(Canvas canvas, Rect rect) {
    final dst = screenBounds;

    canvas.drawCircle(dst.center, dst.width * 0.5, Paint()..color = pointer.isDown ? Colors.blue : Colors.black);

    final text = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )
      ..text = TextSpan(
        text: '${transform.position.x.toInt()}, ${transform.position.y.toInt()}',
        style: const TextStyle(
          letterSpacing: 0.0,
          fontSize: 10.0,
          color: Colors.blue,
        ),
      )
      ..layout();

    text.paint(canvas, Offset(dst.center.dx - text.width * 0.5, dst.bottom + 12.0));
  }

  @override
  bool onPointerDown(Pointer event) {
    pointer.isDown = true;
    pointer.down?.call(event);
    return false;
  }

  @override
  bool onPointerMove(Pointer event) {
    transform.position = event.position.vector;
    pointer.move?.call(event);
    return false;
  }

  @override
  bool onPointerUp(Pointer event) {
    pointer.isDown = false;
    pointer.up?.call(event);
    return false;
  }

  @override
  bool onPointerCancel(Pointer event) {
    pointer.isDown = false;
    pointer.cancel?.call(event);
    return false;
  }

  @override
  bool onPointerHover(Pointer event) {
    transform.position = event.position.vector;
    pointer.hover?.call(event);
    return false;
  }
}
