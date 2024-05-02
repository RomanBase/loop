import 'package:flutter_control/control.dart';
import 'package:loop_editor/editor/control/editor_control.dart';
import 'package:loop_editor/editor/model/editor_component_model.dart';
import 'package:loop_editor/resources/theme.dart';

class EditorTree extends SingleControlWidget<EditorControl> {
  const EditorTree({super.key});

  @override
  Widget build(CoreElement context, EditorControl control) {
    final theme = context.theme;

    return SingleChildScrollView(
      physics: theme.platformPhysics,
      padding: const EdgeInsets.symmetric(vertical: UISize.padding),
      child: ListBuilder<EditorComponentModel>(
        control: control.components,
        builder: (context, items) {
          return Column(
            children: [
              ...items.map((e) => _EditorTreeComponent(
                    control: e,
                  )),
            ],
          );
        },
      ),
    );
  }
}

class _EditorTreeComponent extends ControllableWidget<EditorComponentModel> {
  final int level;

  const _EditorTreeComponent({
    super.key,
    required super.control,
    this.level = 0,
  });

  @override
  Widget build(CoreElement context) {
    final theme = context.theme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CupertinoButton(
          onPressed: control.children.isEmpty ? null : () => control.expand(!control.expanded),
          padding: const EdgeInsets.symmetric(horizontal: UISize.mid, vertical: UISize.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: level * UISize.quarter,
                  ),
                  Expanded(
                    child: Text(
                      control.name,
                      style: theme.font.labelLarge,
                    ),
                  ),
                  const SizedBox(
                    width: UISize.half,
                  ),
                  if (control.children.isNotEmpty)
                    AnimatedRotation(
                        turns: control.expanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.navigate_next,
                          color: theme.scheme.secondary,
                          size: UISize.iconSmall,
                        )),
                ],
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          child: Offstage(
            offstage: !control.expanded,
            child: Padding(
              padding: const EdgeInsets.only(bottom: UISize.padding),
              child: Column(
                children: [
                  ...control.children.map((e) => _EditorTreeComponent(
                        control: e,
                        level: level + 1,
                      )),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
