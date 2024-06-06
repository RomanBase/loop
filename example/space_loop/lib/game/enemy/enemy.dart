import 'dart:math';
import 'dart:ui';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/spaceship/spaceship.dart';
import 'package:space_loop/game/weapon/bullet.dart';

class Enemy extends Sprite with LoopCollisionComponent {
  @override
  int get collisionMask => 0x0011;

  Enemy() : super(asset: Asset.get('mine_0${1 + Random().nextInt(5)}')) {
    //spawn offscreen
    transform.position = Vector2(0.0, -1000.0);
  }

  @override
  void onInit() {
    super.onInit();

    final random = Random();
    final spaceship = findComponent<Spaceship>(root: true)!;

    applyTranslate(
      spaceship.transform.position.offset,
      begin: Offset(random.nextDouble() * getLoop()!.size.width, -100.0),
      duration: const Duration(milliseconds: 3000),
    );

    applyScale(
      Scale.of(0.25 + 0.5 * random.nextDouble()),
      begin: const Scale.of(0.25),
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void onBeginOverlap(LoopCollisionComponent other) {
    super.onBeginOverlap(other);

    if (other is Bullet || other is Spaceship) {
      collisionMask = 0;

      getComponent<DeltaPosition>()?.destroy();

      applyScale(
        const Scale.of(0.0),
        begin: transform.scale,
        reset: true,
        duration: const Duration(milliseconds: 500),
      )
        ..curve = Curves.bounceIn
        ..onFinished = () => destroy();
    }
  }
}

class EnemyEmitter extends ComponentEmitter<Enemy> {
  void fire() => emit(Enemy(), global: true);

  @override
  void onInit() {
    super.onInit();

    _fire();
  }

  void _fire() {
    fire();

    applyTransform(
      DeltaLifetime(duration: const Duration(milliseconds: 1000))..onFinished = () => _fire(),
      reset: true,
    );
  }
}
