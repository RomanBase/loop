import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/resources/res.dart';

class InitControl extends InitLoaderControl {
  @override
  Future load() async {
    await AssetLoader.load(
      Asset.instance,
      images: {
        ..._asset(Res.bodies1, 10, 'body_side'),
        ..._asset(Res.bodies2, 10, 'body_alt'),
        ..._asset(Res.bodies3, 5, 'body'),
        ..._asset(Res.bullets, 12, 'bullet'),
        ..._asset(Res.cabins, 11, 'cabin'),
        ..._asset(Res.engines, 10, 'engine'),
        ..._asset(Res.flames, 11, 'flame'),
        ..._asset(Res.guns1, 10, 'gun'),
        ..._asset(Res.guns2, 10, 'gun_alt'),
        ..._asset(Res.mines, 5, 'mine'),
        ..._asset(Res.missile_flames, 5, 'flame_missile'),
        ..._asset(Res.missiles, 5, 'missile'),
        ..._asset(Res.wings1, 10, 'wing'),
        ..._asset(Res.wings2, 10, 'wing_alt'),
      },
      progress: (value) {
        BroadcastProvider.broadcast<double>(key: 'asset_loader', value: value);
      },
    );

    Asset.instance.printFactoryContent();

    return AppState.main;
  }

  Map<String, String> _asset(dynamic res, int count, String prefix) {
    final output = <String, String>{};

    for (int i = 1; i < count + 1; i++) {
      final key = i < 10 ? '0$i' : '$i';
      output['${prefix}_$key'] = '${res[key]}.png';
    }

    return output;
  }
}
