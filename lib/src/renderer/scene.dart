part of '../../loop.dart';

class SceneViewport extends StatefulWidget {
  final double? width;
  final double? height;
  final double? ratio;
  final Widget child;

  const SceneViewport({
    super.key,
    this.width,
    this.height,
    this.ratio,
    required this.child,
  });

  static SceneViewportState? of(BuildContext context) => context.findRootAncestorStateOfType<SceneViewportState>();

  @override
  State<StatefulWidget> createState() => SceneViewportState();
}

class SceneViewportState extends State<SceneViewport> {
  @override
  Widget build(BuildContext context) => widget.child;
}

class Scene extends SceneWidget {
  final List<Widget> children;
  final List<SceneItemBuilder> builders;

  const Scene({
    super.key,
    super.control,
    super.loop,
    super.width,
    super.height,
    super.ratio,
    this.children = const [],
  })  : builders = const [],
        super(tick: false);

  const Scene.builder({
    super.key,
    super.control,
    super.loop,
    super.width,
    super.height,
    super.ratio,
    this.children = const [],
    this.builders = const [],
  }) : super(tick: true);

  static SceneState? of(BuildContext context) => context.findRootAncestorStateOfType<SceneState>();

  @override
  Widget build(BuildContext context, Widget render, double dt) {
    return Listener(
      onPointerDown: (event) => loop?.onPointerDown(event),
      onPointerMove: (event) => loop?.onPointerMove(event),
      onPointerUp: (event) => loop?.onPointerUp(event),
      onPointerCancel: (event) => loop?.onPointerCancel(event),
      onPointerHover: (event) => loop?.onPointerHover(event),
      child: Stack(
        children: [
          render,
          ...builders.map((e) => e(context, dt)),
          ...children,
        ],
      ),
    );
  }
}

abstract class SceneWidget extends StatefulWidget {
  final ControlLoop? control;
  final LoopScene? loop;
  final bool tick;
  final double? width;
  final double? height;
  final double? ratio;

  const SceneWidget({
    super.key,
    this.control,
    this.loop,
    this.tick = true,
    this.width,
    this.height,
    this.ratio,
  });

  @override
  SceneState createState() => SceneState();

  Widget build(BuildContext context, Widget render, double dt);
}

class SceneState extends State<SceneWidget> {
  late LoopScene loop;
  SceneViewport? viewport;

  Disposable? _sub;
  double dt = 0.0;

  @override
  void initState() {
    super.initState();

    _initScene();
  }

  void _initScene() {
    loop = widget.loop ?? LoopScene();
    viewport = SceneViewport.of(context)?.widget;

    if (!loop.isMounted) {
      loop.mount(widget.control);
    }

    _initTick();
  }

  void _initTick() {
    if (widget.tick) {
      _sub = loop.subscribe((value) {
        setState(() {
          dt = value;
        });
      });
    } else {
      _sub?.dispose();
      _sub = null;
    }
  }

  @override
  void didUpdateWidget(covariant SceneWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loop != oldWidget.loop || widget.control != oldWidget.control) {
      loop.dispose();
      _initScene();
    } else if (widget.tick != oldWidget.tick) {
      _sub?.dispose();
      _initTick();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.build(
      context,
      ViewportBuilder(
        scene: loop,
        width: widget.width ?? viewport?.width,
        height: widget.height ?? viewport?.height,
        ratio: widget.ratio ?? viewport?.ratio,
      ),
      dt,
    );
  }

  @override
  void dispose() {
    loop.dispose();
    _sub?.dispose();
    _sub = null;

    super.dispose();
  }
}
