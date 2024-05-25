import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';

class Bullet extends Sprite with LoopCollisionComponent {
  double speed = -500.0;

  @override
  int get collisionMask => 0x0010;

  @override
  Size? get collisionSize => Size(size.width * 0.25, size.height * 0.5);

  Bullet() : super(asset: Asset.get('bullet_0${1 + Random().nextInt(9)}'));

  @override
  void onInit() {
    super.onInit();

    applyLifetime(const Duration(seconds: 3));
  }

  @override
  void onTick(double dt) {
    super.onTick(dt);

    transform.position += Offset(0.0, speed * dt);
  }

  @override
  void onBeginOverlap(LoopCollisionComponent other) {
    super.onBeginOverlap(other);

    //printDebug('$this overlap $other');
  }

  @override
  String toString() => '$index';

  int index = _counter++;
}

int _counter = 0;
