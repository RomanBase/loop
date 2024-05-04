part of '../../loop.dart';

mixin RenderComponent on LoopComponent {
  Size size = const Size(100.0, 100.0);

  bool visible = true;

  bool checkBounds(Rect rect) => true;

  void render(Canvas canvas, Rect rect) {
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void renderRotated(Canvas canvas, Rect rect, Offset origin, double rotation, void Function(Rect dst) render) {
    if (rotation == 0.0) {
      render(rect);
      return;
    }

    canvas.save();
    canvas.translate(rect.left + origin.dx, rect.top + origin.dy);
    canvas.rotate(rotation);

    render(Rect.fromLTRB(-origin.dx, -origin.dy, rect.width - origin.dx, rect.height - origin.dy));

    canvas.translate(-rect.left - origin.dx, -rect.top - origin.dy);
    canvas.restore();
  }
}

class RenderPainter extends CustomPainter {
  final RenderComponent component;
  final Offset offset;

  RenderPainter({
    required this.component,
    this.offset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    component.size = size;
    component.render(canvas, offset & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BBoxComponent extends SceneComponent with LoopComponent, RenderComponent {
  late LoopComponent _parent;

  @override
  void onAttach(LoopComponent component) {
    _parent = component;

    if (component is RenderComponent) {
      size = component.size;
    }

    printDebug('ATTACH to $component');
  }

  @override
  void onDetach() {}

  @override
  void tick(double dt) {}

  @override
  void render(Canvas canvas, Rect rect) {
    if (_parent is LoopScene) {
      _renderBBox(canvas, '$_parent', rect);

      for (final element in (_parent as LoopScene).items) {
        _renderComponent(element, canvas, rect);
      }
    }

    if (_parent is SceneComponent) {
      _renderComponent(_parent as SceneComponent, canvas, rect);
    }
  }

  void _renderComponent(SceneComponent component, Canvas canvas, Rect rect) {
    if (component == this) {
      return;
    }

    if (component is RenderComponent) {
      rect = component.transform.position & (component.transform.scale & (component as RenderComponent).size);

      _renderBBox(canvas, '$component', rect, component.transform.rotation, Offset(component.origin.dx * component.transform.scale.width, component.origin.dy * component.transform.scale.height));
    }

    component.components.forEach((key, value) {
      if (value is SceneComponent) {
        _renderComponent(component, canvas, rect);
      }
    });
  }

  void _renderBBox(Canvas canvas, String name, Rect rect, [double rotation = 0.0, Offset origin = Offset.zero]) {
    renderRotated(canvas, rect, origin, rotation, (rect) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );

      final text = TextPainter(textDirection: TextDirection.ltr)
        ..text = TextSpan(
          text: name.startsWith('Instance of') ? name.substring(name.indexOf('\'') + 1, name.length - 1) : name,
          style: const TextStyle(
            letterSpacing: 0.0,
            fontSize: 10.0,
            color: Colors.red,
          ),
        );

      text.layout(maxWidth: double.infinity);
      text.paint(canvas, Offset(rect.left, rect.top - 12.0));
    });
  }
}
