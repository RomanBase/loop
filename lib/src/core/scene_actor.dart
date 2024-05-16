part of '../../loop.dart';


class SceneActor extends SceneComponent with RenderComponent {
  Rect get bounds => worldMatrix.position2D & size;


}