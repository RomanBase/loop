part of '../../loop.dart';

class CanvasBuilder extends StatelessWidget {
  final RenderComponent component;

  const CanvasBuilder({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) => CustomPaint(
        painter: RenderPainter(
          component: component,
        ),
        size: (constrains.hasBoundedWidth && constrains.hasBoundedHeight) ? Size(constrains.maxWidth, constrains.maxHeight) : Size.zero,
      ),
    );
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
    if (component.size != size) {
      component.size = size;
    }

    component.render(canvas, offset & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Just for debug
class BBoxRenderComponent extends SceneComponent with RenderComponent {
  late LoopComponent _boxParent;

  @override
  bool get visibleClip => false;

  Color color = Colors.red;

  @override
  void onAttach(LoopComponent component) {
    _boxParent = component;

    if (component is RenderComponent) {
      size = component.size;
    }

    printDebug('BBox ATTACHED to $component');
  }

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
    if (component is BBoxRenderComponent) {
      return;
    }

    if (component is RenderComponent) {
      _renderBBox(
        canvas,
        '$component',
        component.globalTransformMatrix,
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
              rect.left + origin.dx * matrix.scaleX2D,
              rect.top + origin.dy * matrix.scaleY2D,
            ),
            4.0,
            Paint()..color = color);

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
            style: TextStyle(
              letterSpacing: 0.0,
              fontSize: 10.0,
              color: color,
            ),
          );

        text.layout(maxWidth: double.infinity);
        text.paint(canvas, Offset(rect.left, rect.top - 12.0));
      },
    );
  }
}
