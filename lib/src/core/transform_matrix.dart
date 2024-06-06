part of '../../loop.dart';

extension Matrix4Ext on Matrix4 {
  double get scaleX2D => math.sqrt(this[0] * this[0] + this[1] * this[1]);

  double get scaleY2D => math.sqrt(this[4] * this[4] + this[5] * this[5]);

  Offset get position2D => Offset(this[12], this[13]);

  double get angle2D => math.atan2(this[1], this[0]);

  Matrix4 multiplied2DTransform(Matrix4 other, [Matrix4? output]) {
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

    output ??= Matrix4.zero();

    output.setValues(
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

    return output;
  }

  Matrix4 copy() => Matrix4.fromList(storage);
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

/// Just fake inversion Matrix that mimics orthographic projection and view.
class Viewport2D {
  Size screenSize = Size.zero;
  Size viewSize = Size.zero;

  final _matrix = Matrix4.identity();
  final _position = Vector2(0.0, 0.0);
  final _direction = Vector2(1.0, 0.0);
  double _scale = 1.0;

  bool _rebuild = true;

  Offset get origin => Offset(viewSize.width * 0.5 + position[0], viewSize.height * 0.5 + position[1]);

  Matrix4 get matrix => _transformMatrix();

  double get scale => _scale;

  set scale(double value) {
    _scale = value;
    _rebuild = true;
  }

  double get reverseScale => 1.0 / _scale;

  Vector2 get direction => _direction;

  double get rotation => -math.atan2(_direction[1], _direction[0]);

  set rotation(double radians) {
    final s = math.sin(radians);
    final c = math.cos(radians);

    _direction[0] = c;
    _direction[1] = -s;
    _rebuild = true;
  }

  Vector2 get position => _position;

  set position(Vector2 value) {
    _position[0] = value[0];
    _position[1] = value[1];
    _rebuild = true;
  }

  Matrix4 _transformMatrix() {
    if (!_rebuild) {
      return _matrix;
    }

    _rebuild = false;

    final s = math.sin(rotation);
    final c = math.cos(rotation);
    final as = scale.abs();

    _matrix[0] = c * as;
    _matrix[4] = s * as;

    _matrix[1] = -s * as;
    _matrix[5] = c * as;

    _matrix[12] = _position[0] * scale + (screenSize.width * 0.5);
    _matrix[13] = _position[1] * scale + (screenSize.height * 0.5);

    return _matrix;
  }

  Matrix4 multiply(Matrix4 local, [Matrix4? output]) => matrix.multiplied2DTransform(local, output);

  Size updateViewport(Size frame, {double? requiredWidth, double? requiredHeight}) {
    if (frame == screenSize) {
      return viewSize;
    }

    if (requiredWidth != null) {
      scale = frame.width / requiredWidth;
    } else if (requiredHeight != null) {
      scale = frame.height / requiredHeight;
    }

    screenSize = frame;
    viewSize = frame * reverseScale;

    return viewSize;
  }
}
