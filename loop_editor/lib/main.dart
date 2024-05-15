library loop;

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/editor/control/editor_control.dart';
import 'package:loop_editor/editor/presentation/editor.dart';
import 'package:loop_editor/playground/playground.dart';
import 'package:loop_editor/resources/theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Control.initControl(
      debug: true,
      entries: {
        EditorControl: EditorControl(),
        AssetFactory: AssetFactory(),
      },
      modules: [
        ConfigModule(),
        RoutingModule([]),
      ],
      initAsync: () async {
        await AssetLoader.load(
          Asset.instance,
          images: {
            'placeholder': 'assets/placeholder.png',
            'mc': 'assets/mc.png',
          },
          progress: (value) => printDebug('asset loading: $value'),
        );
      },
    );

    return ControlRoot(
      theme: MaterialThemeConfig(
        themes: UITheme.factory,
      ),
      states: [
        AppState.init.build((context) => InitLoader.of(builder: (_) => Container())),
        AppState.main.build((context) => const Playground()),
      ],
      builder: (context, home) => MaterialApp(
        title: 'Flutter Demo',
        theme: context<ThemeConfig>()?.value,
        home: home,
      ),
      onSetupChanged: (context) {
        UITheme.invalidate(context);
      },
    );
  }
}
