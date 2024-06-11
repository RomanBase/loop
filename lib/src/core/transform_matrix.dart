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

  Matrix4 multiplied2DViewBillboard(Matrix4 other, Vector2 scale, [Matrix4? output]) {
    final m00 = scale[0];
    final m03 = this[12];
    final m11 = scale[1];
    final m13 = this[13];

    final n00 = other[0];
    final n01 = other[4];
    final n03 = other[12];
    final n10 = other[1];
    final n11 = other[5];
    final n13 = other[13];

    output ??= Matrix4.zero();

    output.setValues(
      m00 * n00,
      m11 * n10,
      0.0,
      0.0,
      m00 * n01,
      m11 * n11,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      (m00 * n03) + m03,
      (m11 * n13) + m13,
      0.0,
      1.0,
    );

    return output;
  }

  void addSkew(double alfa, double beta) {
    final m10 = math.atan(beta);
    final m01 = math.atan(alfa);

    final n00 = this[0];
    final n01 = this[4];
    final n10 = this[1];
    final n11 = this[5];

    storage[0] = n00 + (m01 * n10);
    storage[1] = (m10 * n00) + n10;

    storage[4] = n01 + (m01 * n11);
    storage[5] = (m10 * n01) + n11;
  }

  Matrix4 copy() => Matrix4.fromList(storage);
}

extension Vector2Ext on Vector2 {
  bool get isZero => x == 0.0 && y == 0.0;

  bool get isOne => x == 1.0 && y == 1.0;

  void move(double step) {
    storage[0] *= step;
    storage[1] *= step;
  }

  Offset get offset => Offset(storage[0], storage[1]);
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
  final _matrixBillboard = Matrix4.identity();
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

  double get rotation => math.atan2(_direction[1], _direction[0]);

  set rotation(double radians) {
    final s = math.sin(radians);
    final c = math.cos(radians);

    _direction[0] = c;
    _direction[1] = s;
    _rebuild = true;
  }

  Vector2 get position => Vector2(-_position[0], -_position[1]);

  set position(Vector2 value) {
    _position[0] = -value[0];
    _position[1] = -value[1];
    _rebuild = true;
  }

  Matrix4 _buildMatrix() {
    if (!_rebuild) {
      return _matrix;
    }

    _rebuild = false;

    final c = _direction[0] * scale;
    final s = _direction[1] * scale;
    final sk10 = math.atan(_skewFactor[1]);
    final sk01 = math.atan(_skewFactor[0]);

    _matrix[0] = c + sk01 * -s;
    _matrix[1] = -s + sk10 * c;
    _matrix[4] = s + sk01 * c;
    _matrix[5] = c + sk10 * s;

    final dx = _position[0] * scale;
    final dy = _position[1] * scale;
    final sx = screenSize.width * 0.5;
    final sy = screenSize.height * 0.5;

    _matrix[12] = dx * _direction[0] + dy * _direction[1] + sx;
    _matrix[13] = -dx * _viewFactor[1] * _direction[1] + _viewFactor[1] * dy * _direction[0] + sy;

    _matrix[0] *= _viewFactor[0];
    _matrix[1] *= _viewFactor[1];
    _matrix[4] *= _viewFactor[0];
    _matrix[5] *= _viewFactor[1];

    _matrixBillboard[0] = c * _viewFactor[0];
    _matrixBillboard[1] = -s * _viewFactor[1];
    _matrixBillboard[4] = s * _viewFactor[0];
    _matrixBillboard[5] = c * _viewFactor[1];
    _matrixBillboard[12] = _matrix[12];
    _matrixBillboard[13] = _matrix[13];

    return _matrix;
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

  void _updateViewScale() {
    _viewScale[0] = _viewFactor[0] * _scale;
    _viewScale[1] = _viewFactor[1] * _scale;
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

  Matrix4 transformViewBillboard(Matrix4 local, bool static, [Matrix4? output]) => static ? matrix.multiplied2DViewBillboard(local, _viewScale, output) : _matrixBillboard.multiplied2DViewTransform(local, output);

  Vector2 transformViewPosition(Vector2 vector) => Vector2(vector[0] * _viewFactor[0], vector[1] * _viewFactor[1]);

  Offset transformLocalPoint(Offset localPoint) {
    final point = ((localPoint * reverseScale) - Offset(viewSize.width * 0.5, viewSize.height * 0.5) - Offset(position[0], position[1]));

    return Offset(point.dx * _viewFactor[0], point.dy * _viewFactor[1]);
  }
}
