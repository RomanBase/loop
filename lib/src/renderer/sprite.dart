part of '../../loop.dart';

class SpriteAction {
  final int offset;
  final int count;
  final double size;
  final int fps;
  final LoopBehavior loop;
  final Axis axis;
  final Curve? blend;

  const SpriteAction({
    this.offset = 0,
    this.count = 1,
    this.size = 256.0,
    this.fps = 20,
    this.loop = LoopBehavior.loop,
    this.axis = Axis.horizontal,
    this.blend,
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

  Rect sheet(int index) => Rect.zero;
}

class Sprite extends SceneActor {
  late ui.Image asset;
  final Map<String, SpriteAction> actions;

  DeltaSequence get sequence => getComponent<DeltaSequence>()!;

  int get frame => getComponent<DeltaSequence>()?.value ?? 0;

  double get blend => getComponent<DeltaSequence>()?.blend ?? 0.0;

  double alpha = 1.0;

  SpriteAction? action;

  Sprite({
    required this.asset,
    this.actions = const {},
    String? initialAction,
  }) {
    if (actions.isNotEmpty) {
      activate(initialAction ?? actions.keys.first);
    }
  }

  void setDefaultSize() {
    size = Size(asset.width.toDouble(), asset.height.toDouble());
  }

  void activate(String actionName) {
    action = actions[actionName];

    if (action == null) {
      return;
    }

    applyTransform(
        DeltaSequence.of(
          offset: action!.offset,
          count: action!.count,
          framesPerSecond: action!.fps,
        )
          ..setLoopBehavior(action!.loop)
          ..curve = action!.blend ?? Curves.linear,
        reset: true);
  }

  @override
  void render(Canvas canvas, Rect rect) {
    canvas.renderComponent(canvas, this, (dst) {
      if (action != null && action!.blend != null && !sequence.atEdge) {
        canvas.drawImageRect(
          asset,
          asset.tile(frame + 1, action),
          dst,
          Paint()..color = Color.fromRGBO(255, 255, 255, blend * alpha),
        );
      }

      canvas.drawImageRect(
        asset,
        asset.tile(frame, action),
        dst,
        Paint()..color = Color.fromRGBO(255, 255, 255, alpha),
      );
    });
  }
}

extension SpriteImage on ui.Image {
  Rect get src => Rect.fromLTRB(0.0, 0.0, width.toDouble(), height.toDouble());

  Rect tile(int index, SpriteAction? action) => action == null ? src : action.tile(index, width, height);
}
