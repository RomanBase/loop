import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/enemy/enemy.dart';
import 'package:space_loop/game/spaceship/spaceship.dart';

final _random = Random();

extension _Hook on CoreElement {
  Loop get loop => use<Loop>(
      value: () => Loop()
        ..mount(ControlLoop.global())
        ..attach(Spaceship())
        ..attach(EnemyEmitter()))!;

  Spaceship get spaceship => loop.findComponent<Spaceship>()!;
}

class SpaceShipEditor extends ControlWidget {
  const SpaceShipEditor({super.key});

  @override
  Widget build(CoreElement context) {
    final spaceship = context.spaceship;

    return Scaffold(
      body: SceneViewport(
        width: 400.0,
        child: Scene(
          loop: context.loop,
          children: [
            const FpsView(),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(64.0),
                child: Wrap(
                  children: [
                    _randomizeComponent(spaceship, spaceship.config.body),
                    _randomizeComponent(spaceship, spaceship.config.bodySide),
                    _randomizeComponent(spaceship, spaceship.config.bodyAlt),
                    _randomizeComponent(spaceship, spaceship.config.cabin),
                    _randomizeComponent(spaceship, spaceship.config.cabinAlt),
                    _randomizeComponent(spaceship, spaceship.config.engine),
                    _randomizeComponent(spaceship, spaceship.config.wing),
                    _randomizeComponent(spaceship, spaceship.config.wingAlt),
                    IconButton(
                      onPressed: () => [
                        spaceship.config.body,
                        spaceship.config.bodySide,
                        spaceship.config.bodyAlt,
                        spaceship.config.cabin,
                        spaceship.config.cabinAlt,
                        spaceship.config.engine,
                        spaceship.config.wing,
                        spaceship.config.wingAlt,
                      ].forEach((e) => spaceship.changeComponent(e, _random.nextInt(e.count))),
                      icon: const Text('all'),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _randomizeComponent(Spaceship spaceship, SpaceshipAssetModel model) => IconButton(
        onPressed: () => spaceship.changeComponent(model, _random.nextInt(model.count)),
        icon: Text(model.key),
      );
}
