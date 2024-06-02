part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;
  bool visibleClip = true;

  int zIndex = 0;

  Rect get screenBounds => Rect.largest;

  bool isVisible(Rect rect) => visible && (!visibleClip || screenBounds.overlaps(rect));

  void render(Canvas canvas, Rect rect);
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
