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
}

mixin PointerDispatcher on LoopComponent implements PointerListener {
  final _pointers = <PointerListener>[];

  void registerPointer(PointerListener listener, {bool primary = false}) => primary ? _pointers.insert(0, listener) : _pointers.add(listener);

  void removePointer(PointerListener listener) => _pointers.remove(listener);

  @override
  bool onPointerDown(PointerEvent event) => _proceed(_pointers, event, (component) => component.onPointerDown(event));

  @override
  bool onPointerHover(PointerEvent event) => _proceed(_pointers, event, (component) => component.onPointerHover(event));

  @override
  bool onPointerUp(PointerEvent event) => _proceed(_pointers, event, (component) => component.onPointerUp(event));

  @override
  bool onPointerMove(PointerEvent event) => _proceed(_pointers, event, (component) => component.onPointerMove(event));

  @override
  bool onPointerCancel(PointerEvent event) => _proceed(_pointers, event, (component) => component.onPointerCancel(event));

  static bool _proceed(Iterable<PointerListener> items, PointerEvent event, bool Function(PointerListener component) action) {
    for (final element in items) {
      if (action.call(element)) {
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
  bool active = true;
  bool primary = false;
}

mixin PointerComponent on SceneComponent, RenderComponent implements PointerListener {
  final pointer = PointerEventHandler();

  @override
  void onInit() {
    super.onInit();

    _loop?.registerPointer(this, primary: pointer.primary);
  }

  @override
  void onDetach() {
    _loop?.removePointer(this);

    super.onDetach();
  }

  @override
  bool onPointerDown(PointerEvent event) {
    if (!pointer.active || !active) {
      return false;
    }

    pointer.isDown = screenBounds.contains(event.localPosition);

    if (pointer.isDown) {
      pointer.down?.call(event);
    }

    return pointer.isDown;
  }

  @override
  bool onPointerMove(PointerEvent event) {
    if (!pointer.active || !active) {
      return false;
    }

    if (pointer.isDown) {
      pointer.isDown = pointer.handleMoveOutside || screenBounds.contains(event.localPosition);

      if (pointer.isDown) {
        pointer.move?.call(event);
        return true;
      }

      pointer.cancel?.call(event);
    }

    return pointer.isDown;
  }

  @override
  bool onPointerUp(PointerEvent event) {
    if (!pointer.active || !active) {
      return false;
    }

    if (pointer.isDown) {
      pointer.isDown = false;

      if (screenBounds.contains(event.localPosition)) {
        pointer.up?.call(event);

        return true;
      }
    }

    return false;
  }

  @override
  bool onPointerCancel(PointerEvent event) {
    if (!pointer.active || !active) {
      return false;
    }

    if (pointer.isDown) {
      pointer.isDown = false;

      pointer.cancel?.call(event);
    }

    return false;
  }

  @override
  bool onPointerHover(PointerEvent event) {
    if (!pointer.active || !active) {
      return false;
    }

    pointer.hover?.call(event);

    return false;
  }
}
