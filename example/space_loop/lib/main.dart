import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:space_loop/game/spaceship/spaceship_editor.dart';
import 'package:space_loop/init/init_control.dart';
import 'package:space_loop/init/init_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Control.initControl(
      debug: !kReleaseMode,
      modules: [
        ConfigModule(),
        RoutingModule([]),
      ],
      entries: {
        ControlLoop: MainLoop(),
        AssetFactory: AssetFactory(),
      },
      factories: {
        InitLoaderControl: (_) => InitControl(),
      },
    );

    return ControlRoot(
      states: [
        AppState.init.build((context) => const InitPage()),
        AppState.main.build((context) => const SpaceShipEditor()),
      ],
      builder: (context, home) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: home,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainLoop extends ControlLoop with LoopCollisionSubsystem {
  static MainLoop main() => ControlLoop.global() as MainLoop;
}
