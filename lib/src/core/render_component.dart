part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;

  int zIndex = 0;

  bool checkBounds(Rect rect) => true;

  void render(Canvas canvas, Rect rect) {
    if (this is RenderQueue) {
      (this as RenderQueue).renderQueue(canvas, rect);
    }
  }

  void renderRotated(Canvas canvas, Rect rect, Offset origin, double rotation, void Function(Rect dst) render) {
    if (rotation == 0.0) {
      render(rect);
      return;
    }

    canvas.save();
    canvas.translate(rect.left + origin.dx, rect.top + origin.dy);
    canvas.rotate(rotation);

    render(Rect.fromLTRB(-origin.dx, -origin.dy, rect.width - origin.dx, rect.height - origin.dy));

    canvas.translate(-rect.left - origin.dx, -rect.top - origin.dy);
    canvas.restore();
  }

  void renderComponent(Canvas canvas, SceneComponent component, void Function(Rect dst) render) {
    final matrix = component.globalTransform;
    final sx = matrix.scaleX;
    final sy = matrix.scaleY;

    final dstOrigin = Offset(component.transform.origin.dx * sx, component.transform.origin.dy * sy);
    final dst = (matrix.position - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle, render);
  }

  void renderRaw(Canvas canvas, Matrix4 matrix, Offset origin, Size size, void Function(Rect dst) render) {
    final sx = matrix.scaleX;
    final sy = matrix.scaleY;

    final dstOrigin = Offset(origin.dx * sx, origin.dy * sy);
    final dst = (matrix.position - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle, render);
  }
}

mixin RenderQueue on LoopComponent {
  final _renderQueue = <RenderComponent>[];

  void pushRenderComponent(RenderComponent component) {
    final index = _renderQueue.lastIndexWhere((element) => element.zIndex <= component.zIndex) + 1;

    _renderQueue.insert(index, component);
  }

  void renderQueue(Canvas canvas, Rect rect) {
    for (final element in _renderQueue) {
      element.render(canvas, rect);
    }

    _renderQueue.clear();
  }
}
