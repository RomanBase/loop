import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/enemy/enemy.dart';

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

    applyLifetime(const Duration(seconds: 2));
    applyScale(
      const Scale.of(1.0),
      begin: const Scale.of(0.25),
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void onTick(double dt) {
    super.onTick(dt);

    transform.position += Vector2(0.0, speed * dt);
  }

  @override
  void onBeginOverlap(LoopCollisionComponent other) {
    super.onBeginOverlap(other);

    if (other is Enemy) {
      collisionMask = 0;

      applyScale(
        const Scale.of(2.0),
        begin: transform.scale,
        reset: true,
        duration: const Duration(milliseconds: 100),
      ).onFinished = () => destroy();

      applyOpacity(
        0.0,
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  @override
  String toString() => 'B$index';

  int index = _counter++;
}

int _counter = 0;
