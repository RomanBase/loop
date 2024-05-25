part of '../../loop.dart';

class Pointer {
  final PointerEvent event;

  final Offset position;

  Offset get localPosition => event.localPosition;

  Offset get screenPosition => event.position;

  const Pointer(this.event, this.position);
}

abstract class PointerListener {
  bool onPointerDown(Pointer event);

  bool onPointerMove(Pointer event);

  bool onPointerUp(Pointer event);

  bool onPointerCancel(Pointer event);

  bool onPointerHover(Pointer event);
}

mixin PointerDispatcher on LoopComponent {
  final _pointers = <PointerListener>[];

  void registerPointer(PointerListener listener, {bool primary = false}) => primary ? _pointers.insert(0, listener) : _pointers.add(listener);

  void removePointer(PointerListener listener) => _pointers.remove(listener);

  bool onPointerDown(PointerEvent event) => _proceed(_pointers, event, (component, event) => component.onPointerDown(event));

  bool onPointerMove(PointerEvent event) => _proceed(_pointers, event, (component, event) => component.onPointerMove(event));

  bool onPointerUp(PointerEvent event) => _proceed(_pointers, event, (component, event) => component.onPointerUp(event));

  bool onPointerCancel(PointerEvent event) => _proceed(_pointers, event, (component, event) => component.onPointerCancel(event));

  bool onPointerHover(PointerEvent event) => _proceed(_pointers, event, (component, event) => component.onPointerHover(event));

  Pointer transformPointer(PointerEvent event) => Pointer(event, event.localPosition);

  bool _proceed(Iterable<PointerListener> items, PointerEvent event, bool Function(PointerListener component, Pointer event) action) {
    final pointer = transformPointer(event);

    for (final element in items) {
      if (action.call(element, pointer)) {
        return true;
      }
    }

    return false;
  }
}

class PointerEventHandler {
  void Function(Pointer event)? down;
  void Function(Pointer event)? move;
  void Function(Pointer event)? up;
  void Function(Pointer event)? cancel;
  void Function(Pointer event)? hover;

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
  bool onPointerDown(Pointer event) {
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
  bool onPointerMove(Pointer event) {
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
  bool onPointerUp(Pointer event) {
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
  bool onPointerCancel(Pointer event) {
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
  bool onPointerHover(Pointer event) {
    if (!pointer.active || !active) {
      return false;
    }

    pointer.hover?.call(event);

    return false;
  }
}