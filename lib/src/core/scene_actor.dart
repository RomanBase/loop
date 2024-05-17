part of '../../loop.dart';

class SceneActor extends SceneComponent with RenderComponent {
  @override
  void render(Canvas canvas, Rect rect) {
    // TODO: implement render
  }
}

abstract class PointerListener {
  bool onPointerDown(PointerEvent event);

  bool onPointerMove(PointerEvent event);

  bool onPointerUp(PointerEvent event);

  bool onPointerCancel(PointerEvent event);

  bool onPointerHover(PointerEvent event);

  static bool _proceed(Iterable<LoopComponent> items, PointerEvent event, bool Function(PointerListener component) action) {
    for (final element in items) {
      if (!element.active || element is! PointerListener) {
        continue;
      }

      if (action.call(element as PointerListener)) {
        return true;
      }
    }

    return false;
  }
}

class PointerEventHandler {
  void Function(PointerEvent event)? down;
  void Function(PointerEvent event)? move;
  void Function(PointerEvent event)? up;
  void Function(PointerEvent event)? cancel;
  void Function(PointerEvent event)? hover;

  bool handleMoveOutside = true;
  bool isDown = false;
}

mixin PointerComponent on SceneComponent, RenderComponent implements PointerListener {
  final pointer = PointerEventHandler();

  @override
  bool onPointerDown(PointerEvent event) {
    pointer.isDown = screenBounds.contains(event.localPosition);

    if (pointer.isDown) {
      pointer.down?.call(event);
    }

    return pointer.isDown || PointerListener._proceed(components.values, event, (component) => component.onPointerDown(event));
  }

  @override
  bool onPointerMove(PointerEvent event) {
    if (pointer.isDown) {
      pointer.isDown = pointer.handleMoveOutside || screenBounds.contains(event.localPosition);

      if (pointer.isDown) {
        pointer.move?.call(event);
        return true;
      }

      pointer.cancel?.call(event);
    }

    return pointer.isDown || PointerListener._proceed(components.values, event, (component) => component.onPointerMove(event));
  }

  @override
  bool onPointerUp(PointerEvent event) {
    if (pointer.isDown) {
      pointer.isDown = false;

      if (screenBounds.contains(event.localPosition)) {
        pointer.up?.call(event);

        return true;
      }
    }

    return PointerListener._proceed(components.values, event, (component) => component.onPointerUp(event));
  }

  @override
  bool onPointerCancel(PointerEvent event) {
    if (pointer.isDown) {
      pointer.isDown = false;

      pointer.cancel?.call(event);
    }

    return PointerListener._proceed(components.values, event, (component) => component.onPointerCancel(event));
  }

  @override
  bool onPointerHover(PointerEvent event) {
    pointer.hover?.call(event);

    return PointerListener._proceed(components.values, event, (component) => component.onPointerHover(event));
  }
}
