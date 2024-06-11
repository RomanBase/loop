part of '../../loop.dart';

enum RenderScreenType {
  basic,
  complex,
  billboard,
  billboardRelative,
}

abstract class SceneActor extends SceneComponent with RenderComponent {
  RenderScreenType renderType = RenderScreenType.complex;

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
  void render(Canvas canvas, Rect rect) {
    switch (renderType) {
      case RenderScreenType.basic:
        canvas.renderComponent(this, (dst) => renderComponent(canvas, dst));
        break;
      default:
        canvas.save();
        canvas.transform(screenMatrix.storage);
        renderComponent(canvas, Rect.fromLTWH(-size.width * transform.origin.dx, -size.height * transform.origin.dy, size.width, size.height));
        canvas.restore();
    }
  }

  @override
  Matrix4 getScreenSpace() {
    switch (renderType) {
      case RenderScreenType.billboard:
        return getLoop()?.viewport.transformViewBillboard(transform.matrix, true, _screenMatrixStorage) ?? transform.matrix;
      case RenderScreenType.billboardRelative:
        return getLoop()?.viewport.transformViewBillboard(transform.matrix, false, _screenMatrixStorage) ?? transform.matrix;
      default:
        return super.getScreenSpace();
    }
  }

  void renderComponent(Canvas canvas, Rect rect);
}

class EmptySceneActor extends SceneActor {
  @override
  bool get visible => false;

  @override
  void renderComponent(Canvas canvas, Rect rect) {}
}
