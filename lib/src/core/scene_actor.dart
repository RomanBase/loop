part of '../../loop.dart';

class SceneActor extends SceneComponent with RenderComponent, HitBoxComponent {
  @override
  void render(Canvas canvas, Rect rect) {
    // TODO: implement render
  }
}

mixin HitBoxComponent on SceneComponent, RenderComponent {
  Rect get bounds => worldMatrix.position2D & size;

  void onPressed() {}

  void onPointerDown(Offset offset) {}

  void onPointerUpdate(Offset offset) {}

  void onPointerUp(bool canceled) {}

  void onHit(HitBoxComponent other, dynamic impact) {}
}
