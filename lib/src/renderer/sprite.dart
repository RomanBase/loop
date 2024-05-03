part of '../../loop.dart';

class SpriteAction {
  int offset = 0;
  int count = 1;
  LoopBehavior loop = LoopBehavior.loop;
}

extension SpriteImage on ui.Image {
  Rect get src => Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble());

  Rect tile(int index, double size) {
    assert(width % size == 0.0, 'Invalid Tile size');

    final len = index * size;
    final x = (len / width).floorToDouble();
    final y = (width - len) / size;

    return Rect.fromLTWH(x, y, size, size);
  }
}

class Sprite extends SceneComponent with RenderComponent {
  final ui.Image asset;
  final Map<String, SpriteAction> actions;

  Sprite({
    required this.asset,
    this.actions = const {},
  });

  @override
  void render(Canvas canvas, Rect rect) {
    final dst = transform.position & size;

    canvas.drawImageRect(
      asset,
      asset.src,
      dst,
      Paint(),
    );

    super.render(canvas, rect);
  }
}
