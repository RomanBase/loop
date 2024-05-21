import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/spaceship/spaceship.dart';

final _random = Random();

extension _Hook on CoreElement {
  LoopScene get loop => use<LoopScene>(value: () => LoopScene()..attach(SpaceshipComponent()))!;

  SpaceshipComponent get spaceship => loop.findComponent<SpaceshipComponent>()!;
}

class SpaceShipEditor extends ControlWidget {
  const SpaceShipEditor({super.key});

  @override
  void onInit(Map args, CoreContext context) {
    super.onInit(args, context);
  }

  @override
  Widget build(CoreElement context) {
    final spaceship = context.spaceship;

    return Scaffold(
      body: Scene(
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
                    icon: Text('all'),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _randomizeComponent(SpaceshipComponent spaceship, SpaceshipAssetModel model) => IconButton(
        onPressed: () => spaceship.changeComponent(model, _random.nextInt(model.count)),
        icon: Text(model.key),
      );
}
