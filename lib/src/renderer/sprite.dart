part of '../../loop.dart';

class SpriteAction {
  final int offset;
  final int count;
  final double size;
  final int fps;
  final LoopBehavior loop;
  final Axis axis;

  const SpriteAction({
    this.offset = 0,
    this.count = 1,
    this.size = 256.0,
    this.fps = 4,
    this.loop = LoopBehavior.loop,
    this.axis = Axis.horizontal,
  });

  Rect tile(int index, int width, int height) {
    assert(width % size == 0.0, 'Invalid Tile size');

    late double x;
    late double y;

    if (axis == Axis.horizontal) {
      final rows = width / size;

      y = (index / rows).floorToDouble();
      x = index - (rows * y);
    } else {
      final columns = height / size;

      x = (index / columns).floorToDouble();
      y = index - (columns * x);
    }

    return Rect.fromLTWH(x * size, y * size, size, size);
  }
}

extension SpriteImage on ui.Image {
  Rect get src => Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble());

  Rect tile(int index, SpriteAction? action) => action == null ? src : action.tile(index, width, height);
}

class Sprite extends SceneComponent with RenderComponent {
  final ui.Image asset;
  final Map<String, SpriteAction> actions;

  DeltaSequence get sequence => getTransform<DeltaSequence>()!;

  int get frame => getTransform<DeltaSequence>()?.value ?? 0;

  double get morph => getTransform<DeltaSequence>()?.morph ?? 0.0;

  SpriteAction? action;

  Sprite({
    required this.asset,
    this.actions = const {},
  }) {
    if (actions.isNotEmpty) {
      activate(actions.keys.first);
    }
  }

  void activate(String actionName) {
    action = actions[actionName];

    if (action == null) {
      return;
    }

    applyTransform(
        DeltaSequence.sub(
          offset: action!.offset,
          count: action!.count,
          framesPerSecond: action!.fps,
        )..setLoopBehavior(action!.loop),
        reset: true);
  }

  void activateSequence(List<String> sequence) {}

  @override
  void render(Canvas canvas, Rect rect) {
    final dst = transform.position & size;

    canvas.drawImageRect(
      asset,
      asset.tile(frame, action),
      dst,
      Paint(),
    );

    if (action != null) {
      if (morph > 0.0 && frame < sequence.end) {
        canvas.drawImageRect(
          asset,
          asset.tile(frame + 1, action),
          dst,
          Paint()..color = Colors.white.withOpacity(morph),
        );
      }
    }
  }
}
