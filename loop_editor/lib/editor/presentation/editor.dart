import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/editor/control/editor_loop.dart';
import 'package:loop_editor/editor/presentation/editor_tree.dart';
import 'package:loop_editor/resources/theme.dart';

extension _EditorHook on CoreContext {
  EditorLoop get control => use(value: () => EditorLoop())!;

  EditorScene get loop => use(value: () => EditorScene()..mount(control))!;
}

class Editor extends ControlWidget {
  const Editor({super.key});

  @override
  Widget build(CoreContext context) {
    final theme = context.theme;

    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 120.0,
            color: theme.scheme.primaryContainer,
          ),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 240.0,
                  height: double.infinity,
                  color: theme.scheme.primaryContainer,
                  child: const EditorTree(),
                ),
                Expanded(
                  child: EditorFrame(
                    loop: context.loop,
                    width: 400.0,
                    height: 800.0,
                  ),
                ),
                Container(
                  width: 240.0,
                  height: double.infinity,
                  color: theme.scheme.primaryContainer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditorFrame extends ControlWidget {
  final double? width;
  final double? height;
  final EditorScene loop;

  const EditorFrame({
    super.key,
    required this.loop,
    this.width,
    this.height,
  });

  @override
  Widget build(CoreElement context) {
    final theme = context.theme;

    return Container(
      color: theme.scheme.tertiaryContainer,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: width,
              height: height,
              color: Colors.white,
              child: Scene(
                loop: loop,
                width: width,
                height: height,
              ),
            ),
          ),
          FpsView(
            alignment: Alignment.topRight,
            control: loop.control,
          ),
        ],
      ),
    );
  }
}
