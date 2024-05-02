import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';

class EditorVariables {
  final children = <EditorComponentModel>[];

  bool expanded = true;
  bool visible = true;
  bool exported = true;
}

class EditorComponentModel extends BaseModel with NotifierComponent {
  final _variables = EditorVariables();

  late String name;
  Type type = SceneComponent;

  List<EditorComponentModel> get children => _variables.children;

  bool get expanded => _variables.expanded;

  bool get visible => _variables.visible;

  bool get exported => _variables.exported;

  EditorComponentModel operator [](int index) => _variables.children[index];

  void add(EditorComponentModel component) {
    _variables.children.add(component);
    notify();
  }

  void remove(EditorComponentModel component) {
    _variables.children.remove(component);
    notify();
  }

  void expand(bool value) {
    _variables.expanded = value;

    if (!value) {
      for (final element in _variables.children) {
        element.expand(value);
      }
    }

    notify();
  }

  void visibility(bool value) {
    _variables.visible = value;

    for (final element in _variables.children) {
      element.visibility(value);
    }

    notify();
  }

  void export(bool value) {
    _variables.exported = value;
    notify();
  }
}
