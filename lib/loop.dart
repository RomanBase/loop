library loop;

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;
import 'package:control_core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

part 'src/core/asset_factory.dart';

part 'src/core/control_loop.dart';

part 'src/core/loop_scene.dart';

part 'src/core/render_component.dart';

part 'src/core/scene_component.dart';

part 'src/core/state_component.dart';

part 'src/core/transform_component.dart';

part 'src/renderer/builder.dart';

part 'src/renderer/scene.dart';

part 'src/renderer/sprite.dart';

part 'src/ui/fps_view.dart';

extension Vector2Ext on Vector2 {
  bool get isZero => x == 0.0 && y == 0.0;

  bool get isOne => x == 1.0 && y == 1.0;
}

extension OffsetExt on Offset {
  static const Offset one = Offset(1.0, 1.0);

  bool get isZero => dx == 0.0 && dy == 0.0;

  bool get isOne => dx == 1.0 && dy == 1.0;
}

class Scale {
  static const Offset one = Offset(1.0, 1.0);

  static Offset of(double value) => Offset(value, value);
}
