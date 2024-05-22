part of '../../loop.dart';

mixin CollisionComponent on LoopCollision, RenderComponent {
  Rect? _rect;

  @override
  Rect get bounds => _rect ??= _objectBounds();

  Rect _objectBounds() {
    final matrix = worldMatrix;
    final sx = matrix.scaleX2D.abs();
    final sy = matrix.scaleY2D.abs();

    final size = Size(this.size.width * sx, this.size.height * sy);
    final dstOrigin = Offset(transform.origin.dx * size.width, transform.origin.dy * size.height);
    final dst = (matrix.position2D - dstOrigin) & size;

    return dst;
  }

  @override
  void onTick(double dt) {
    _rect = null;
    super.onTick(dt);
  }
}

abstract class BoundingBox extends SceneComponent with LoopCollision {
  Size get size;

  Rect? _rect;

  @override
  Rect get bounds => _rect ??= _objectBounds();

  Rect _objectBounds() {
    final matrix = worldMatrix;
    final sx = matrix.scaleX2D.abs();
    final sy = matrix.scaleY2D.abs();

    final size = Size(this.size.width * sx, this.size.height * sy);
    final dstOrigin = Offset(transform.origin.dx * size.width, transform.origin.dy * size.height);
    final dst = (matrix.position2D - dstOrigin) & size;

    return dst;
  }

  @override
  void onTick(double dt) {
    _rect = null;
    super.onTick(dt);
  }
}
