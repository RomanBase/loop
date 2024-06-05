part of '../../loop.dart';

extension Matrix4Ext on Matrix4 {
  double get scaleX2D => math.sqrt(this[0] * this[0] + this[1] * this[1]);

  double get scaleY2D => math.sqrt(this[4] * this[4] + this[5] * this[5]);

  Offset get position2D => Offset(this[12], this[13]);

  double get angle2D => math.atan2(this[1], this[0]);

  Matrix4 multiplied2DTransform(Matrix4 other) {
    final m00 = this[0];
    final m01 = this[4];
    final m03 = this[12];
    final m10 = this[1];
    final m11 = this[5];
    final m13 = this[13];

    final n00 = other[0];
    final n01 = other[4];
    final n03 = other[12];
    final n10 = other[1];
    final n11 = other[5];
    final n13 = other[13];

    return Matrix4(
      (m00 * n00) + (m01 * n10),
      (m10 * n00) + (m11 * n10),
      0.0,
      0.0,
      (m00 * n01) + (m01 * n11),
      (m10 * n01) + (m11 * n11),
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      (m00 * n03) + (m01 * n13) + m03,
      (m10 * n03) + (m11 * n13) + m13,
      0.0,
      1.0,
    );
  }
}

/// Currently holds only local transforms
class TransformMatrix {
  final _matrix = Matrix4.identity();

  Offset origin = const Offset(0.5, 0.5);

  Offset _position = Offset.zero;

  Offset get position => _position;

  set position(Offset value) {
    _position = value;
    _matrix[12] = value.dx;
    _matrix[13] = value.dy;
  }

  Scale _scale = Scale.one;

  Scale get scale => _scale;

  set scale(Scale value) {
    _scale = value;
    _rebuildMatrix = true;
  }

  double _rotation = 0.0;

  double get rotation => _rotation;

  set rotation(double value) {
    _rotation = value;
    _rebuildMatrix = true;
  }

  Matrix4 get matrix {
    if (!_rebuildMatrix) {
      return _matrix;
    }

    _rebuildMatrix = false;

    final s = math.sin(rotation);
    final c = math.cos(rotation);

    _matrix[0] = c * scale.width.abs();
    _matrix[4] = s * scale.width.abs();

    _matrix[1] = -s * scale.height.abs();
    _matrix[5] = c * scale.height.abs();

    return _matrix;
  }

  bool _rebuildMatrix = false;
}

/// Just fake inversion Matrix that mimics orthographic projection when multiplied with model matrix.
/// Viewport size is 'ignored' because we are using mobile space (dp) resolution and we don't deal with frustrum in pure 2d scene. With proper scaling we can fake world size.
class ViewportMatrix {
  final _transform = TransformMatrix();
  final _view = TransformMatrix();

  Matrix4 get matrix => _transform.matrix;

  Offset originOffset = Offset.zero;

  Offset get position => -_view.position + originOffset;

  set position(Offset value) => _view.position = -value + originOffset;

  double get rotation => -_view.rotation;

  set rotation(double value) => _view.rotation = -value;

  double get scale => _transform.scale.width;

  set scale(double value) => _transform.scale = Scale.of(value);

  double get reverseScale => 1.0 / scale;

  Matrix4 multiply(Matrix4 local) {
    var vp = matrix.multiplied2DTransform(_view.matrix);
    //vp.translate(originOffset.dx, originOffset.dy);
    vp = vp.multiplied2DTransform(local);

    return vp;
  }

  Size updateViewport(Size frame, {double? requiredWidth, double? requiredHeight}) {
    if (requiredWidth != null) {
      scale = frame.width / requiredWidth;
    } else if (requiredHeight != null) {
      scale = frame.height / requiredHeight;
    }

    _view._rebuildMatrix = true;
    _transform._rebuildMatrix = true;

    return frame * reverseScale;
  }
}
