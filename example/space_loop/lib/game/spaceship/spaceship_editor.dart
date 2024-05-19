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
                  _randomizeComponent(context.spaceship, context.spaceship.config.body),
                  _randomizeComponent(context.spaceship, context.spaceship.config.bodySide),
                  _randomizeComponent(context.spaceship, context.spaceship.config.bodyAlt),
                  _randomizeComponent(context.spaceship, context.spaceship.config.cabin),
                  _randomizeComponent(context.spaceship, context.spaceship.config.cabinAlt),
                  _randomizeComponent(context.spaceship, context.spaceship.config.engine),
                  _randomizeComponent(context.spaceship, context.spaceship.config.wing),
                  _randomizeComponent(context.spaceship, context.spaceship.config.wingAlt),
                  IconButton(
                    onPressed: () => [
                      context.spaceship.config.body,
                      context.spaceship.config.bodySide,
                      context.spaceship.config.bodyAlt,
                      context.spaceship.config.cabin,
                      context.spaceship.config.cabinAlt,
                      context.spaceship.config.engine,
                      context.spaceship.config.wing,
                      context.spaceship.config.wingAlt,
                    ].forEach((e) => context.spaceship.changeComponent(e, _random.nextInt(e.count))),
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
