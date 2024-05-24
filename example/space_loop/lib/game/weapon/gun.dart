import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/weapon/bullet.dart';

class Gun extends ComponentEmitter<Bullet> with RenderComponent {
  void fire() => emit(Bullet()..transform.position = worldMatrix.position2D);

  @override
  void onInit() {
    super.onInit();

    zIndex = -1;
    _fire();
  }

  void _fire() {
    fire();

    applyTransform(
      DeltaLifetime(duration: const Duration(milliseconds: 1200))..onFinished = () => _fire(),
      reset: true,
    );
  }

  @override
  void render(Canvas canvas, Rect rect) {
    emittedObjects.forEach((key, value) {
      value.render(canvas, rect);
    });
  }
}
