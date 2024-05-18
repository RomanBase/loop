part of '../../loop.dart';

typedef SceneItemBuilder = Widget Function(BuildContext context, double dt);

abstract class ComponentWidget extends StatefulWidget {
  final SceneComponent component;

  const ComponentWidget({
    super.key,
    required this.component,
  });

  @override
  ComponentBuilderState createState() => ComponentBuilderState();

  Widget build(BuildContext context, double dt);
}

class ComponentBuilder extends ComponentWidget {
  final SceneItemBuilder builder;

  const ComponentBuilder({
    super.key,
    required super.component,
    required this.builder,
  });

  @override
  ComponentBuilderState createState() => ComponentBuilderState();

  @override
  Widget build(BuildContext context, double dt) => builder(context, dt);
}

class ComponentBuilderState extends State<ComponentWidget> {
  late Disposable _sub;
  double dt = 0.0;

  @override
  void initState() {
    super.initState();

    _initComponent();
  }

  void _initComponent() {
    _sub = widget.component.subscribe(() {
      if (widget.component.isMounted) {
        setState(() {
          dt = widget.component._loop!.value;
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant ComponentBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.component != oldWidget.component) {
      _sub.dispose();
      _initComponent();
    }
  }

  @override
  Widget build(BuildContext context) => widget.build(context, dt);

  @override
  void dispose() {
    _sub.dispose();

    super.dispose();
  }
}

class SceneComponentBuilder extends SceneComponentWidget {
  final SceneItemBuilder builder;

  const SceneComponentBuilder({
    super.key,
    required super.component,
    super.filterQuality,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, double dt) => builder(context, dt);
}

abstract class SceneComponentWidget extends StatefulWidget {
  final SceneComponent component;
  final FilterQuality? filterQuality;

  const SceneComponentWidget({
    super.key,
    required this.component,
    this.filterQuality,
  });

  @override
  SceneComponentState createState() => SceneComponentState();

  Widget build(BuildContext context, double dt);
}

class SceneComponentState extends State<SceneComponentWidget> {
  SceneComponent get component => widget.component;

  @override
  void initState() {
    super.initState();

    if (!component.isMounted) {
      Scene.of(context)?.loop.attach(component);
    }

    component.subscribe(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: component.transform.matrix,
      origin: component.transform.origin,
      filterQuality: widget.filterQuality,
      child: Opacity(
        opacity: component.deltaOpacity ?? 1.0,
        child: widget.build(context, component._loop!.value),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    component.dispose();
  }
}
