library ci;

import 'package:control_shell/shell.dart';

final shell = root(path: '../');

Future<void> runAsync(String name, Future<void> Function(ControlShell shell) action) => shell.runAsync(name, () => action(shell));
