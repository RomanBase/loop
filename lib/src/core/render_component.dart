part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;
  bool visibleClip = true;

  int zIndex = 0;

  Rect? _screenBounds;

  Rect get screenBounds => _screenBounds ??= _renderBounds();

  bool isVisible(Rect rect) => visible && (!visibleClip || screenBounds.overlaps(rect));

  Rect _renderBounds() {
    if (this is SceneComponent) {
      final component = this as SceneComponent;
      final matrix = component.screenMatrix;
      final sx = matrix.scaleX2D.abs();
      final sy = matrix.scaleY2D.abs();

      final size = Size(this.size.width * sx, this.size.height * sy);
      final dstOrigin = Offset(component.transform.origin.dx * size.width, component.transform.origin.dy * size.height);
      final dst = (matrix.position2D - dstOrigin) & size;

      return dst;
    }

    return Rect.fromLTWH(0.0, 0.0, size.width, size.height);
  }

  @override
  void tick(double dt) {
    _screenBounds = null;
    super.tick(dt);
  }

  void render(Canvas canvas, Rect rect);

  void renderComponent(Canvas canvas, SceneComponent component, void Function(Rect dst) render) {
    canvas.renderRotated(
      screenBounds,
      Offset(screenBounds.width * component.transform.origin.dx, screenBounds.height * component.transform.origin.dy),
      component.screenMatrix.angle2D,
      component.transform.scale,
      render,
    );
  }
}

mixin RenderQueue {
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
