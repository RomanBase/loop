import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';

class Mouse extends SceneActor with PointerComponent {
  Mouse() {
    zIndex = 999;
    pointer.primary = true;

    size = const Size.square(32.0);
    visibleClip = false;
  }

  @override
  void render(Canvas canvas, Rect rect) {
    final viewport = getLoop()!.viewport;
    final offset = (transform.position + Offset(viewport.position.x, viewport.position.y)) * viewport.scale;

    final dst = Rect.fromLTWH(
      offset.dx + viewport.screenSize.width * 0.5 - size.width * 0.5,
      offset.dy + viewport.screenSize.height * 0.5 - size.height * 0.5,
      size.width,
      size.height,
    );

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
  }

  @override
  bool onPointerDown(Pointer event) {
    pointer.isDown = true;
    pointer.down?.call(event);
    return false;
  }

  @override
  bool onPointerMove(Pointer event) {
    transform.position = event.position;
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
    transform.position = event.position;
    pointer.hover?.call(event);
    return false;
  }
}
