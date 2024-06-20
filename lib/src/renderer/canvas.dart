part of '../../loop.dart';

extension CanvasRender on Canvas {
  static final _rectFaces = Uint16List.fromList([0, 1, 2, 0, 2, 3]);
  static final _rectUvs = Float32List.fromList([0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0]);

  void _renderRotated(Rect rect, Offset origin, double rotation, Scale scale, void Function(Rect dst) render) {
    if (rotation == 0.0 && !scale.isNegative) {
      render(rect);
      return;
    }

    save();
    translate(rect.left + origin.dx, rect.top + origin.dy);
    rotate(rotation);
    this.scale(scale.dx, scale.dy);

    render(Rect.fromLTRB(-origin.dx, -origin.dy, rect.width - origin.dx, rect.height - origin.dy));

    restore();
  }

  void renderComponent(SceneActor component, void Function(Rect dst) render) {
    _renderRotated(
      component.screenBounds,
      Offset(component.screenBounds.width * component.transform.origin.dx, component.screenBounds.height * component.transform.origin.dy),
      component.screenMatrix.angle2D,
      component.transform.scale,
      render,
    );
  }

  void renderBox(Matrix4 matrix, Offset origin, Size size, void Function(Rect dst) render) {
    final sx = matrix.scaleX2D;
    final sy = matrix.scaleY2D;

    size = Size(size.width * sx, size.height * sy);
    final dstOrigin = Offset(origin.dx * size.width, origin.dy * size.height);
    final dst = (matrix.position2D - dstOrigin) & size;

    _renderRotated(dst, dstOrigin, matrix.angle2D, Scale(sx, sy), render);
  }

  void renderRaw(Matrix4 matrix, void Function() render) {
    save();
    transform(matrix.storage);
    render();

    restore();
  }

  void drawRectMesh(Rect dst, Paint paint) {
    drawVertices(
      ui.Vertices.raw(
        VertexMode.triangles,
        Float32List.fromList([dst.left, dst.bottom, dst.right, dst.bottom, dst.right, dst.top, dst.left, dst.top]),
        textureCoordinates: _rectUvs,
        indices: _rectFaces,
      ),
      BlendMode.src,
      paint,
    );
  }
}

/// Just for debug
class BBoxRenderComponent<T extends SceneComponent> extends SceneComponent with RenderComponent {
  late LoopComponent _boxParent;

  @override
  bool get unbounded => false;

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

    if (_boxParent is Loop) {
      // render also scene bounds while rendering generic bounds
      if (shouldRender(EmptySceneActor())) {
        final viewport = (_boxParent as Loop).viewport;
        _renderBBox(canvas, '$_boxParent', Matrix4.identity()..scale(viewport.scale));
      }

      for (final element in (_boxParent as Loop).items) {
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

  void _renderSBox(Canvas canvas, String name, Rect rect, [Offset origin = Offset.zero]) {
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
  }
}
