part of '../../loop.dart';

abstract class SceneActor extends SceneComponent with RenderComponent {}

class EmptySceneActor extends SceneActor {
  @override
  void render(Canvas canvas, Rect rect) {}
}
