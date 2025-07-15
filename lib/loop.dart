library loop;

export 'package:vector_math/vector_math_64.dart' hide Colors;

import 'dart:collection';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:vector_math/vector_math.dart' as v_math;
import 'package:flutter/services.dart' show rootBundle;
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:control_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'src/collision/collision_component.dart';

part 'src/collision/collision_subsystem.dart';

part 'src/core/asset_factory.dart';

part 'src/core/component_lookup.dart';

part 'src/core/control_loop.dart';

part 'src/core/emit_component.dart';

part 'src/core/loop.dart';

part 'src/core/render_component.dart';

part 'src/core/scene_actor.dart';

part 'src/core/scene_component.dart';

part 'src/core/scene_component_delta_transform.dart';

part 'src/core/state_component.dart';

part 'src/core/transform_component.dart';

part 'src/core/transform_matrix.dart';

part 'src/io/pointer.dart';

part 'src/renderer/big_mesh_solver.dart';

part 'src/renderer/canvas.dart';

part 'src/renderer/skeletal_mesh.dart';

part 'src/renderer/sprite.dart';

part 'src/renderer/static_mesh.dart';

part 'src/ui/builder.dart';

part 'src/ui/fps_view.dart';

part 'src/ui/scene.dart';

part 'src/ui/viewport.dart';

extension Vector2Ext on Vector2 {
  bool get isZero => x == 0.0 && y == 0.0;

  bool get isOne => x == 1.0 && y == 1.0;

  Offset get offset => Offset(storage[0], storage[1]);
}

extension OffsetExt on Offset {
  bool get isZero => dx == 0.0 && dy == 0.0;

  bool get isOne => dx == 1.0 && dy == 1.0;

  Vector2 get vector => Vector2(dx, dy);
}

extension SizeExt on Size {
  bool get isZero => width == 0.0 && height == 0.0;

  bool get isOne => width == 1.0 && height == 1.0;

  bool get isNegative => width < 0.0 || height < 0.0;

  Size reverse(double rx, [double? ry]) => Size(width * (1.0 / rx), height * (1.0 / (ry ?? rx)));

  Size scale(double rx, [double? ry]) => Size(width * rx, height * (ry ?? rx));
}

class Scale {
  final double x;
  final double y;

  bool get isNegative => x < 0.0 || y < 0.0;

  double get dx => x < 0.0 ? -1.0 : 1.0;

  double get dy => y < 0.0 ? -1.0 : 1.0;

  const Scale(this.x, this.y);

  const Scale.of(double value) : this(value, value);

  static const Scale one = Scale(1.0, 1.0);

  Scale operator *(Scale other) => Scale(x * other.x, y * other.y);

  Size operator &(Size other) => Size(x * other.width, y * other.height);

  static Scale lerp(Scale a, Scale b, double t) => Scale(a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t);
}
