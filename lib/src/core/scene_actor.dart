part of '../../loop.dart';

abstract class SceneActor extends SceneComponent with RenderComponent {
  Rect? _screenBounds;

  @override
  Rect get screenBounds => _screenBounds ??= _renderBounds();

  Rect _renderBounds() {
    final matrix = screenMatrix;
    final sx = matrix.scaleX2D.abs();
    final sy = matrix.scaleY2D.abs();

    final size = Size(this.size.width * sx, this.size.height * sy);
    final dstOrigin = Offset(transform.origin.dx * size.width, transform.origin.dy * size.height);
    final dst = (matrix.position2D - dstOrigin) & size;

    return dst;
  }

  @override
  void tick(double dt) {
    _screenBounds = null;
    super.tick(dt);
  }

  @override
  void render(Canvas canvas, Rect rect) => canvas.renderComponent(this, (dst) => renderComponent(canvas, dst));

  void renderComponent(Canvas canvas, Rect rect);
}

class EmptySceneActor extends SceneActor {
  @override
  bool get visible => false;

  @override
  void renderComponent(Canvas canvas, Rect rect) {}
}
