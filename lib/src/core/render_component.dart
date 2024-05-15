part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;
  bool visibleClip = true;

  int zIndex = 0;

  bool isVisible(Rect rect) => visible && (!visibleClip || renderBounds().overlaps(rect));

  Rect renderBounds() {
    if (this is SceneComponent) {
      final component = this as SceneComponent;
      final matrix = component.globalTransformMatrix;
      final sx = matrix.scaleX2D;
      final sy = matrix.scaleY2D;

      final dstOrigin = Offset(component.transform.origin.dx * sx, component.transform.origin.dy * sy);
      final dst = (matrix.position2D - dstOrigin) & Size(size.width * sx, size.height * sy);

      return dst;
    }

    return Rect.fromLTWH(0.0, 0.0, size.width, size.height);
  }

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
    final matrix = component.globalTransformMatrix;
    final sx = matrix.scaleX2D;
    final sy = matrix.scaleY2D;

    final dstOrigin = Offset(component.transform.origin.dx * sx, component.transform.origin.dy * sy);
    final dst = (matrix.position2D - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle2D, render);
  }

  void renderRaw(Canvas canvas, Matrix4 matrix, Offset origin, Size size, void Function(Rect dst) render) {
    final sx = matrix.scaleX2D;
    final sy = matrix.scaleY2D;

    final dstOrigin = Offset(origin.dx * sx, origin.dy * sy);
    final dst = (matrix.position2D - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle2D, render);
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
