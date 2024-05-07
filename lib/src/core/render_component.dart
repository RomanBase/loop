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

  void renderComponent(Canvas canvas, SceneComponent component, void Function(Rect dst) render) {
    final matrix = component.globalTransform;
    final sx = matrix.scaleX;
    final sy = matrix.scaleY;

    final dstOrigin = Offset(component.transform.origin.dx * sx, component.transform.origin.dy * sy);
    final dst = (matrix.position - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle, render);
  }

  void renderRaw(Canvas canvas, Matrix4 matrix, Offset origin, Size size, void Function(Rect dst) render) {
    final sx = matrix.scaleX;
    final sy = matrix.scaleY;

    final dstOrigin = Offset(origin.dx * sx, origin.dy * sy);
    final dst = (matrix.position - dstOrigin) & Size(size.width * sx, size.height * sy);

    renderRotated(canvas, dst, dstOrigin, matrix.angle, render);
  }
}

mixin RenderQueue on LoopComponent {
  final componentQueue = <RenderComponent>[];

  void renderQueue(Canvas canvas, Rect rect) {
    for (final element in componentQueue) {
      element.render(canvas, rect);
    }

    componentQueue.clear();
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
  late LoopComponent _boxParent;

  @override
  void onAttach(LoopComponent component) {
    _boxParent = component;

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
    if (_boxParent is LoopScene) {
      _renderBBox(canvas, '$_boxParent', Matrix4.identity());

      for (final element in (_boxParent as LoopScene).items) {
        _renderComponent(element, canvas, rect);
      }
    }

    if (_boxParent is SceneComponent) {
      _renderComponent(_boxParent as SceneComponent, canvas, rect);
    }
  }

  void _renderComponent(SceneComponent component, Canvas canvas, Rect rect) {
    if (component == this) {
      return;
    }

    if (component is RenderComponent) {
      _renderBBox(
        canvas,
        '$component',
        component.globalTransform,
        component.transform.origin,
        (component as RenderComponent).size,
      );
    }

    component.components.forEach((key, value) {
      if (value is SceneComponent) {
        _renderComponent(value, canvas, rect);
      }
    });
  }

  void _renderBBox(Canvas canvas, String name, Matrix4 matrix, [Offset origin = Offset.zero, Size? size]) {
    renderRaw(
      canvas,
      matrix,
      origin,
      size ?? this.size,
      (rect) {
        canvas.drawCircle(
            Offset(
              rect.left + origin.dx * matrix.scaleX,
              rect.top + origin.dy * matrix.scaleY,
            ),
            4.0,
            Paint()..color = Colors.red);

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
      },
    );
  }
}
