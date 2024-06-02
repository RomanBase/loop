import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'package:loop_editor/editor/model/editor_component_model.dart';

class EditorControl extends BaseControl with LazyControl, ReferenceCounter {
  final components = ListControl<EditorComponentModel>();

  @override
  void onInit(Map args) {
    super.onInit(args);

    add('root');
    components[0]?.add(EditorComponentModel()..name = 'component');
  }

  void add(String name, [Type type = Loop]) {
    final component = EditorComponentModel()
      ..name = name
      ..type = type;

    components.add(component);
  }

  void delete(EditorComponentModel component) {
    components.remove(component);
    component.dispose();
  }

  @override
  void dispose() {
    super.dispose();

    components.dispose();
  }
}
