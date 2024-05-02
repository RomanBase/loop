part of '../../loop.dart';

class Scene extends SceneWidget {
  final List<Widget> children;
  final List<SceneItemBuilder> builders;

  const Scene({
    super.key,
    super.control,
    super.loop,
    this.children = const [],
  })  : builders = const [],
        super(tick: false);

  const Scene.builder({
    super.key,
    super.control,
    super.loop,
    this.children = const [],
    this.builders = const [],
  }) : super(tick: true);

  static SceneState of(BuildContext context) => context.findRootAncestorStateOfType<SceneState>()!;

  @override
  Widget build(BuildContext context, double dt) {
    return Stack(
      children: [
        ...builders.map((e) => e(context, dt)),
        ...children,
      ],
    );
  }
}

abstract class SceneWidget extends StatefulWidget {
  final ControlLoop? control;
  final LoopScene? loop;
  final bool tick;

  const SceneWidget({
    super.key,
    this.control,
    this.loop,
    this.tick = true,
  });

  @override
  SceneState createState() => SceneState();

  Widget build(BuildContext context, double dt);
}

class SceneState extends State<SceneWidget> {
  late LoopScene loop;

  Disposable? _sub;
  double dt = 0.0;

  @override
  void initState() {
    super.initState();

    _initScene();
  }

  void _initScene() {
    loop = widget.loop ?? LoopScene();

    if (!loop.isMounted) {
      loop.mount(widget.control ?? ControlLoop.main());
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
  Widget build(BuildContext context) => widget.build(context, dt);

  @override
  void dispose() {
    loop.dispose();

    super.dispose();
  }
}
