library loop;

import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/editor/control/editor_control.dart';
import 'package:loop_editor/editor/presentation/editor.dart';
import 'package:loop_editor/playground/loop_playground.dart';
import 'package:loop_editor/resources/theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Control.initControl(
      entries: {EditorControl: EditorControl(), AssetFactory: AssetFactory()},
      modules: [
        ConfigModule(),
        RoutingModule([]),
      ],
      initAsync: () async {
        await Asset.instance.loadImage('assets/placeholder.png');
        await Asset.instance.loadImage('assets/mc.png');
      },
      debug: true,
    );

    return ControlRoot(
      theme: MaterialThemeConfig(
        themes: UITheme.factory,
      ),
      states: [
        AppState.init.build((context) => InitLoader.of(builder: (_) => Container())),
        AppState.main.build((context) => const LoopPlayground()),
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
