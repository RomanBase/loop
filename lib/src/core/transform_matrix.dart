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

  Matrix4 multiplied2DViewTransform(Matrix4 other, [Matrix4? output]) {
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

  Matrix4 multiplied2DViewBillboard(Matrix4 camera, Vector2 viewScale, bool static, Matrix4 other, [Matrix4? output]) {
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

    if (static) {
      output.setValues(
        viewScale[0] * n00,
        viewScale[1] * n10,
        0.0,
        0.0,
        viewScale[0] * n01,
        viewScale[1] * n11,
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
    } else {
      final c00 = camera[0];
      final c01 = camera[4];
      final c10 = camera[1];
      final c11 = camera[5];

      output.setValues(
        (c00 * n00) + (c01 * n10),
        (c10 * n00) + (c11 * n10),
        0.0,
        0.0,
        (c00 * n01) + (c01 * n11),
        (c10 * n01) + (c11 * n11),
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

    return output;
  }

  Matrix4 copy() => Matrix4.fromList(storage);
}

class TransformMatrix {
  final _matrix = Matrix4.identity();
  final _direction = Vector2(1.0, 0.0);
  final _position = Vector2(0.0, 0.0);

  Offset origin = const Offset(0.5, 0.5);
  bool _rebuild = true;

  Vector2 get position => _position;

  set position(Vector2 value) {
    _position[0] = value[0];
    _position[1] = value[1];

    _matrix[12] = value[0];
    _matrix[13] = value[1];
  }

  Scale _scale = Scale.one;

  Scale get scale => _scale;

  set scale(Scale value) {
    _scale = value;
    _rebuild = true;
  }

  Vector2 get direction => _direction;

  double get rotation => math.atan2(_direction[1], _direction[0]);

  set rotation(double radians) {
    final s = math.sin(radians);
    final c = math.cos(radians);

    _direction[0] = c;
    _direction[1] = s;
    _rebuild = true;
  }

  Matrix4 get matrix {
    if (!_rebuild) {
      return _matrix;
    }

    _rebuild = false;

    final s = math.sin(rotation);
    final c = math.cos(rotation);

    _matrix[0] = c * scale.x.abs();
    _matrix[1] = -s * scale.y.abs();

    _matrix[4] = s * scale.x.abs();
    _matrix[5] = c * scale.y.abs();

    return _matrix;
  }
}

/// Just fake 2D inversion Matrix that mimics orthographic projection & view.
class Viewport2D extends BaseModel with NotifierComponent {
  Rect screenFrame = Rect.zero;
  Size screenSize = Size.zero;
  Size viewSize = Size.zero;

  final _matrix = Matrix4.identity();
  final _matrixCamera = Matrix4.identity();
  final _position = Vector2(0.0, 0.0);
  final _direction = Vector2(1.0, 0.0);
  final _viewFactor = Vector2(1.0, 1.0);
  final _skewFactor = Vector2(0.0, 0.0);
  final _viewScale = Vector2(1.0, 1.0);
  double _scale = 1.0;

  bool _rebuild = true;

  Offset get origin => Offset(viewSize.width * 0.5 + position[0], viewSize.height * 0.5 + position[1]);

  Matrix4 get matrix => _buildMatrix();

  double get scale => _scale;

  set scale(double value) {
    _scale = value;
    _rebuild = true;
    _updateViewScale();
  }

  double get reverseScale => 1.0 / _scale;

  Vector2 get direction => _direction;

  double get rotation => rotationRad * _toDegrees;

  double get rotationRad => -math.atan2(_direction[1], _direction[0]);

  set rotation(double radians) => rotationRad = radians * _toRadian;

  set rotationRad(double radians) {
    final s = math.sin(-radians);
    final c = math.cos(-radians);

    _direction[0] = c;
    _direction[1] = s;
    _rebuild = true;
  }

  Vector2 get position => Vector2(-_position[0] * _viewFactor[0], -_position[1] * _viewFactor[1]);

  set position(Vector2 value) {
    _position[0] = -value[0] * _viewFactor[0];
    _position[1] = -value[1] * _viewFactor[1];
    _rebuild = true;
  }

  Matrix4 _buildMatrix() {
    if (!_rebuild) {
      return _matrix;
    }

    _rebuild = false;

    final c = _direction[0];
    final s = _direction[1];
    final sk10 = math.atan(_skewFactor[1]);
    final sk01 = math.atan(_skewFactor[0]);

    final dx = _position[0];
    final dy = _position[1];
    final w = screenSize.width * 0.5;
    final h = screenSize.height * 0.5;

    final m00 = c + sk10 * -s;
    final m10 = s + sk10 * c;
    final m01 = -s + sk01 * c;
    final m11 = c + sk01 * s;

    // view projection matrix
    _matrix[0] = m00 * _viewScale[0];
    _matrix[1] = m10 * _viewScale[1];
    _matrix[4] = m01 * _viewScale[0];
    _matrix[5] = m11 * _viewScale[1];

    _matrix[12] = dx * _viewScale[0] * m00 + dy * _viewScale[1] * m01 + w;
    _matrix[13] = -dx * _viewScale[1] * m10 + dy * _viewScale[0] * m11 + h;

    // view camera matrix
    _matrixCamera[0] = c * _viewScale[0];
    _matrixCamera[1] = s * _viewScale[1];
    _matrixCamera[4] = -s * _viewScale[0];
    _matrixCamera[5] = c * _viewScale[1];

    _matrixCamera[12] = _matrix[12];
    _matrixCamera[13] = _matrix[13];

    return _matrix;
  }

  void _updateViewScale() {
    _viewScale[0] = _viewFactor[0] * _scale;
    _viewScale[1] = _viewFactor[1] * _scale;
  }

  void updatePerspective({double? dirX, double? dirY, double? skewAlpha, double? skewBeta}) {
    if (dirX != null) {
      _viewFactor[0] = dirX;
    }

    if (dirY != null) {
      _viewFactor[1] = dirY;
    }

    if (skewAlpha != null) {
      _skewFactor[0] = skewAlpha;
    }

    if (skewBeta != null) {
      _skewFactor[1] = skewBeta;
    }

    _updateViewScale();
  }

  void updateViewportFrame(Size size, {double? requiredWidth, double? requiredHeight, double framePadding = 32.0, ValueCallback<Size>? onChanged}) {
    if (size == screenSize) {
      return;
    }

    if (requiredWidth != null) {
      scale = size.width / requiredWidth;
    } else if (requiredHeight != null) {
      scale = size.height / requiredHeight;
    }

    viewSize = size * reverseScale;
    screenSize = size;
    screenFrame = Rect.fromLTRB(
      -framePadding,
      -framePadding,
      (viewSize.width * scale) + framePadding,
      (viewSize.height * scale) + framePadding,
    );

    onChanged?.call(viewSize);
    notify();
  }

  Matrix4 transformViewPerspective(Matrix4 local, [Matrix4? output]) => matrix.multiplied2DViewTransform(local, output);

  Matrix4 transformViewBillboard(Matrix4 local, bool static, [Matrix4? output]) => matrix.multiplied2DViewBillboard(_matrixCamera, _viewScale, static, local, output);

  //TODO: add un-rotation/skew modifiers
  Vector2 transformViewPoint(Vector2 local, {bool reverse = false}) {
    local = Vector2(local[0] * _viewFactor[0], local[1] * _viewFactor[1]);

    if (reverse) {
      local = (local + position) * scale;
      local[0] += screenSize.width * 0.5;
      local[1] += screenSize.height * 0.5;
    }

    return local;
  }

  //TODO: add rotation/skew modifiers
  Offset transformLocalPoint(Offset local) {
    final point = ((local * reverseScale) - Offset(viewSize.width * 0.5, viewSize.height * 0.5) - Offset(position[0], position[1]));

    return Offset(point.dx * _viewFactor[0], point.dy * _viewFactor[1]);
  }
}
