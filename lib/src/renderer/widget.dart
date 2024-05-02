part of '../../loop.dart';

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
      Scene.of(context).loop.add(component);
    }

    component.subscribe(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: component.transform.matrix,
      origin: component.origin,
      filterQuality: widget.filterQuality,
      child: SizedBox(
        width: component.deltaSize?.width,
        height: component.deltaSize?.height,
        child: Opacity(
          opacity: component.deltaOpacity ?? 1.0,
          child: widget.build(context, component.loop.value),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();

    component.dispose();
  }
}
