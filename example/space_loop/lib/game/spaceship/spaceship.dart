import 'dart:math';

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/weapon/gun.dart';
import 'package:space_loop/model/pref_model.dart';
import 'dart:math' as math;

class SpaceshipAssetModel {
  late final PrefModel<String?> _pref;
  late final String asset;

  final int count;
  final int offset;

  String get key => _pref.key;

  String get value => _pref.value!;

  set value(String val) => _pref.value = val;

  SpaceshipAssetModel(String key, this.count, {this.offset = 1, int defaultValue = 0, String? asset}) {
    this.asset = asset ?? key;
    _pref = PrefModel.string(key, defaultValue: getAsset(defaultValue));
  }

  String getAsset(int index) {
    final num = offset + index;

    return '${asset}_${num < 10 ? '0$num' : num}';
  }

  void clear() => _pref.clear();
}

class SpaceshipConfig extends BaseModel with PrefsProvider {
  final body = SpaceshipAssetModel('body', 5);
  final bodyAlt = SpaceshipAssetModel('body_alt', 10);
  final bodySide = SpaceshipAssetModel('body_side', 10);

  final cabin = SpaceshipAssetModel('cabin', 5);
  final cabinAlt = SpaceshipAssetModel('cabin_alt', 6, offset: 6, asset: 'cabin');
  final engine = SpaceshipAssetModel('engine', 10);

  final wing = SpaceshipAssetModel('wing', 10);
  final wingAlt = SpaceshipAssetModel('wing_alt', 10);

  final flame = SpaceshipAssetModel('flame', 5);

  void clean() {
    body.clear();
    bodyAlt.clear();
    bodySide.clear();
    cabin.clear();
    cabinAlt.clear();
    engine.clear();
    wing.clear();
    wingAlt.clear();
    flame.clear();
  }
}

class SpaceshipComponent extends SceneComponent with LoopCollisionComponent {
  final config = SpaceshipConfig();

  @override
  Size? get collisionSize => const Size(240.0, 260.0);

  @override
  void onInit() {
    super.onInit();

    getLoop()!.frame.subscribe((value) {
      transform.position = getLoop()!.size.bottomCenter(const Offset(0.0, 300));
      _activateSideJiggle();
    }, current: false).once();

    config.clean();
    build();

    _activateFlame(1);
    _activateFlame(2);
    _activateFlame(3);
  }

  void build() {
    transform.scale = const Scale.of(0.5);

    attach(Gun()..transform.position = const Offset(0.0, -65.0));

    attach(
      Sprite(asset: Asset.get(config.flame.value))
        ..transform.origin = const Offset(0.5, 0.0)
        ..transform.position = const Offset(0.0, 60.0)
        ..setDefaultSize(),
      slot: '${config.flame.key}1',
    );

    attach(
      Sprite(asset: Asset.get(config.flame.value))
        ..transform.origin = const Offset(0.5, 0.0)
        ..transform.position = const Offset(0.0, 60.0)
        ..alpha = 0.35
        ..setDefaultSize(),
      slot: '${config.flame.key}2',
    );

    attach(
      Sprite(asset: Asset.get(config.flame.value))
        ..transform.origin = const Offset(0.5, 0.0)
        ..transform.position = const Offset(0.0, 60.0)
        ..alpha = 0.35
        ..setDefaultSize(),
      slot: '${config.flame.key}3',
    );

    attach(
      Sprite(asset: Asset.get(config.engine.value))
        ..transform.position = const Offset(0.0, 60.0)
        ..setDefaultSize(),
      slot: config.engine.key,
    );

    attach(
      Sprite(asset: Asset.get(config.body.value))..setDefaultSize(),
      slot: config.body.key,
    );

    attach(
      LoopCollisionActor()
        ..transform.position = const Offset(0.0, -35.0)
        ..attach(Sprite(asset: Asset.get(config.bodyAlt.value))
          ..transform.position = const Offset(-40.0, 0.0)
          ..setDefaultSize())
        ..attach(Sprite(asset: Asset.get(config.bodyAlt.value))
          ..transform.position = const Offset(40.0, 0.0)
          ..transform.scale = const Scale(-1.0, 1.0)
          ..setDefaultSize()),
      slot: config.bodyAlt.key,
    );

    attach(
      LoopCollisionActor()
        ..transform.position = const Offset(0.0, 16.0)
        ..attach(Sprite(asset: Asset.get(config.wing.value))
          ..transform.position = const Offset(-70.0, 0.0)
          ..setDefaultSize())
        ..attach(Sprite(asset: Asset.get(config.wing.value))
          ..transform.position = const Offset(70.0, 0.0)
          ..transform.scale = const Scale(-1.0, 1.0)
          ..setDefaultSize()),
      slot: config.wing.key,
    );

    attach(
      SceneComponent()
        ..attach(Sprite(asset: Asset.get(config.bodySide.value))
          ..transform.position = const Offset(-35.0, 0.0)
          ..setDefaultSize())
        ..attach(Sprite(asset: Asset.get(config.bodySide.value))
          ..transform.position = const Offset(35.0, 0.0)
          ..transform.scale = const Scale(-1.0, 1.0)
          ..setDefaultSize()),
      slot: config.bodySide.key,
    );

    attach(
      SceneComponent()
        ..transform.position = const Offset(0.0, -20.0)
        ..attach(Sprite(asset: Asset.get(config.wingAlt.value))
          ..transform.position = const Offset(-35.0, 0.0)
          ..setDefaultSize())
        ..attach(Sprite(asset: Asset.get(config.wingAlt.value))
          ..transform.position = const Offset(35.0, 0.0)
          ..transform.scale = const Scale(-1.0, 1.0)
          ..setDefaultSize()),
      slot: config.wingAlt.key,
    );

    attach(
      Sprite(asset: Asset.get(config.cabinAlt.value))
        ..transform.position = const Offset(0.0, 40.0)
        ..setDefaultSize(),
      slot: config.cabinAlt.key,
    );

    attach(
      Sprite(asset: Asset.get(config.cabin.value))
        ..transform.position = const Offset(0.0, -65.0)
        ..setDefaultSize()
        ..attach(LoopColliderComponent()),
      slot: config.cabin.key,
    );
  }

  void _activateFlame(int index) {
    final flame = getComponent<Sprite>('${config.flame.key}$index');

    if (flame == null) {
      return;
    }

    final random = Random();
    flame.rotate((random.nextDouble() - 0.5) * 6.0, duration: const Duration(milliseconds: 400), reset: true);
    flame.scale(Scale(0.75 + 0.25 * random.nextDouble(), 0.75 + 0.5 * random.nextDouble()), duration: Duration(milliseconds: 400 + random.nextInt(300)), reset: true)
      ..curve = Curves.bounceInOut
      ..onFinished = () => _activateFlame(index);
  }

  void _activateSideJiggle() {
    final random = Random();
    translate(getLoop()!.size.bottomCenter(const Offset(0.0, -200)) + Offset(64.0 * (random.nextDouble() - 0.5) * 2.0, 32.0 * (random.nextDouble() - 0.5) * 2.0))
      ..curve = Curves.easeInOut
      ..onFinished = () => _activateSideJiggle();
  }

  void changeComponent(SpaceshipAssetModel pref, int index) {
    final component = getComponent<SceneComponent>(pref.key)!;

    final activityCheck = component.findComponents<DeltaTransform>();
    if (activityCheck.any((element) => element.active)) {
      return;
    }

    final sprites = component is Sprite ? [component] : component.findComponents<Sprite>();

    for (final element in sprites) {
      final originScale = element.transform.scale;
      final originPosition = element.transform.position;

      element.scale(const Scale.of(3.0) & originScale, duration: const Duration(milliseconds: 300), reset: true)
        ..curve = Curves.ease
        ..onFinished = () {
          element.asset = Asset.get(pref.value);
          element.setDefaultSize();
          element.scale(originScale, duration: const Duration(milliseconds: 500)).curve = Curves.easeInQuad;
        };

      element.opacity(0.0, duration: const Duration(milliseconds: 300), reset: true)
        ..until(hold: WaitCondition(duration: const Duration(milliseconds: 100)))
        ..curve = Curves.ease;
      element.opacity(1.0, duration: const Duration(milliseconds: 400))
        ..until(hold: WaitCondition(duration: const Duration(milliseconds: 100)))
        ..curve = Curves.easeInQuad
        ..onValue = (value) => element.alpha = value;

      element.translate(Offset(originPosition.dx * 5.0, originPosition.dy * 3.0), duration: const Duration(milliseconds: 200)).curve = Curves.ease;
      element.translate(originPosition, duration: const Duration(milliseconds: 600)).curve = Curves.easeInQuad;
    }

    if (component is! Sprite) {
      final originPosition = component.transform.position;
      component.translate(Offset(originPosition.dx, originPosition.dy * 3.0), duration: const Duration(milliseconds: 200)).curve = Curves.ease;
      component.translate(originPosition, duration: const Duration(milliseconds: 600)).curve = Curves.easeInQuad;
    }

    pref.value = pref.getAsset(index);
  }
}
