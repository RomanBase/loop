import 'package:flutter_control/control.dart';
import 'package:loop_editor/editor/presentation/editor_tree.dart';
import 'package:loop_editor/resources/theme.dart';

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
                const Expanded(
                  child: EditorFrame(),
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
  final Size bounds;
  final Size size;

  const EditorFrame({
    super.key,
    this.size = const Size(360.0, 820.0),
    this.bounds = const Size(2048.0, 2048.0),
  });

  @override
  Widget build(CoreElement context) {
    final theme = context.theme;
    final matrix = context.value<Matrix4>(value: Matrix4.identity(), stateNotifier: true);

    return Stack(
      children: [
        GestureDetector(
          onHorizontalDragUpdate: (event) {
            matrix.value!.translate(event.delta.dx, event.delta.dy);
            context.notifyState();
          },
          onVerticalDragUpdate: (event) {
            matrix.value!.translate(event.delta.dx, event.delta.dy);
            context.notifyState();
          },
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: theme.scheme.tertiaryContainer,
            ),
            child: Center(
              child: Transform(
                transform: matrix.value!,
                child: Container(
                  width: size.width,
                  height: size.height,
                  color: theme.scheme.surfaceVariant,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(UISize.half),
            child: Text(
              '${size.width} x ${size.height}',
              style: theme.font.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}
