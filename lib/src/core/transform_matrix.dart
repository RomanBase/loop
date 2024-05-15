part of '../../loop.dart';

extension Matrix4Ext on Matrix4 {
  double get scaleX => Vector3(this[0], this[1], this[2]).length;

  double get scaleY => Vector3(this[4], this[5], this[6]).length;

  Offset get position => Offset(this[12], this[13]);

  double get angle {
    final v = getRotation().right;

    return math.atan2(v[1], v[0]);
  }
}

class TransformMatrix {
  final _matrix = Matrix4.identity();

  Offset origin = Offset.zero;

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
    _markedForRebuild = true;
  }

  double _rotation = 0.0;

  double get rotation => _rotation;

  set rotation(double value) {
    _rotation = value;
    _markedForRebuild = true;
  }

  bool _markedForRebuild = false;

  Matrix4 get matrix {
    if (!_markedForRebuild) {
      return _matrix;
    }

    _markedForRebuild = false;

    double s = math.sin(rotation);
    double c = math.cos(rotation);

    _matrix[0] = c * scale.width;
    _matrix[1] = s * scale.width;

    _matrix[4] = -s * scale.height;
    _matrix[5] = c * scale.height;

    return _matrix;
  }

  Rect rect(Size size) {
    final dstOrigin = Offset(origin.dx * scale.width, origin.dy * scale.height);
    return (matrix.position - dstOrigin) & Size(size.width * scale.width, size.height * scale.height);
  }

  Matrix4 of(SceneComponent? parent, [SceneViewport? viewport]) {
    if (parent == null) {
      return viewport?.combine(matrix) ?? matrix;
    }

    return parent.globalTransform.multiplied(matrix);
  }
}
