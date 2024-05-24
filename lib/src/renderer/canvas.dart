part of '../../loop.dart';

extension CanvasRender on Canvas {
  void renderRotated(Rect rect, Offset origin, double rotation, Scale scale, void Function(Rect dst) render) {
    if (rotation == 0.0 && !scale.isNegative) {
      render(rect);
      return;
    }

    save();
    translate(rect.left + origin.dx, rect.top + origin.dy);
    rotate(rotation);
    this.scale(scale.width < 0.0 ? -1.0 : 1.0, scale.height < 0.0 ? -1.0 : 1.0);

    render(Rect.fromLTRB(-origin.dx, -origin.dy, rect.width - origin.dx, rect.height - origin.dy));

    restore();
  }

  void renderBox(Matrix4 matrix, Offset origin, Size size, void Function(Rect dst) render) {
    final sx = matrix.scaleX2D;
    final sy = matrix.scaleY2D;

    size = Size(size.width * sx, size.height * sy);
    final dstOrigin = Offset(origin.dx * size.width, origin.dy * size.height);
    final dst = (matrix.position2D - dstOrigin) & size;

    renderRotated(dst, dstOrigin, matrix.angle2D, Scale(sx, sy), render);
  }

  void renderRaw(Matrix4 matrix, void Function() render) {
    save();
    transform(matrix.storage);
    render();

    restore();
  }
}

class ViewportBuilder extends StatelessWidget {
  final LoopScene scene;
  final double? width;
  final double? height;
  final double? ratio;

  const ViewportBuilder({
    super.key,
    required this.scene,
    this.width,
    this.height,
    this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) => CustomPaint(
        painter: ViewportPainter(
          widget: this,
        ),
        size: (constrains.hasBoundedWidth && constrains.hasBoundedHeight) ? Size(constrains.maxWidth, constrains.maxHeight) : Size.zero,
      ),
    );
  }
}

class ViewportPainter extends CustomPainter {
  final ViewportBuilder widget;

  const ViewportPainter({
    required this.widget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    widget.scene.updateViewportSize(
      size,
      requiredWidth: widget.width,
      requiredHeight: widget.height,
    );

    widget.scene.render(canvas, Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class CanvasBuilder extends StatelessWidget {
  final RenderComponent component;

  const CanvasBuilder({
    super.key,
    required this.component,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return CustomPaint(
          painter: ComponentPainter(
            component: component,
          ),
          size: (constrains.hasBoundedWidth && constrains.hasBoundedHeight) ? Size(constrains.maxWidth, constrains.maxHeight) : Size.zero,
        );
      },
    );
  }
}

class ComponentPainter extends CustomPainter {
  final RenderComponent component;
  final Offset offset;

  const ComponentPainter({
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
class BBoxRenderComponent<T extends SceneComponent> extends SceneComponent with RenderComponent {
  late LoopComponent _boxParent;

  @override
  bool get visibleClip => false;

  Color color = Colors.red;

  bool Function(SceneComponent component) shouldRender = (component) => component is T;

  Size Function(T component) componentSize = (component) => (component is RenderComponent) ? (component as RenderComponent).size : Size.zero;

  Iterable<T> Function()? componentList;

  @override
  void onAttach(LoopComponent component) {
    super.onAttach(component);

    _boxParent = component;

    if (component is RenderComponent) {
      size = component.size;
    }
  }

  @override
  void onDetach() {
    super.onDetach();

    printDebug('BBox DETACHED');
  }

  @override
  void render(Canvas canvas, Rect rect) {
    if (componentList != null) {
      final items = componentList!();

      for (T component in items) {
        if (shouldRender(component)) {
          _renderBBox(
            canvas,
            '$component',
            component.screenMatrix,
            component.transform.origin,
            componentSize(component),
          );
        }
      }

      return;
    }

    if (_boxParent is LoopScene) {
      // render also scene bounds while rendering generic bounds
      if (shouldRender(SceneActor())) {
        _renderBBox(canvas, '$_boxParent', Matrix4.identity()..scale((_boxParent as LoopScene).viewport.scale));
      }

      for (final element in (_boxParent as LoopScene).items) {
        if (element is SceneComponent) {
          _renderComponent(element, canvas, rect);
        }
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

    if (shouldRender(component)) {
      _renderBBox(
        canvas,
        '$component',
        component.screenMatrix,
        component.transform.origin,
        componentSize(component as T),
      );
    }

    component.components.forEach((key, value) {
      if (value is SceneComponent) {
        _renderComponent(value, canvas, rect);
      }
    });
  }

  void _renderBBox(Canvas canvas, String name, Matrix4 matrix, [Offset origin = Offset.zero, Size? size]) {
    size ??= this.size;

    canvas.renderBox(
      matrix,
      origin,
      size,
      (rect) {
        canvas.drawCircle(
          rect.topLeft + Offset(rect.width * origin.dx, rect.height * origin.dy),
          4.0,
          Paint()..color = color,
        );

        canvas.drawRect(
          rect,
          Paint()
            ..color = color
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
