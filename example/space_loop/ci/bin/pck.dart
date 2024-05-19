import 'dart:io';

import 'package:ci/ci.dart' as ci;
import 'package:control_shell/ci/ci_package.dart' as pck;
import 'package:control_shell/ci/ci_git.dart' as git;
import 'package:control_shell/shell.dart';

const _libs = ['core', 'presentation', 'router'];
const _modular = ['app', 'modules', 'platforms'];

void main(List<String> args) async {
  await ci.runAsync(
    'generate export files',
    (shell) => pck.buildProjectLibs(
      exclude: [
        ..._libs,
        ..._modular,
      ],
      provider: false,
    ).then((value) => git.addFiles(shell, value)),
  );

  for (final lib in _libs) {
    await ci.runAsync(
      'generate $lib provider files',
      (shell) => pck
          .buildLib(
            directory: libDirectory(lib),
            provider: true,
          )
          .then((value) => git.addFiles(shell, value)),
    );
  }

  for (final module in _modular) {
    await ci.runAsync(
      'generate $module provider files',
      (shell) => pck
          .buildModuleLibs(
            directory: libDirectory(module),
            provider: true,
          )
          .then((value) => git.addFiles(shell, value)),
    );
  }
}

void buildPck(Directory directory) {
  Directory dir = parentDir(directory, 'lib');

  if (_modular.contains(dir.name)) {
    if (!_modular.contains(directory.name)) {
      dir = parentDir(directory, dir.name);
    } else {
      return;
    }
  }

  if (dir.name == 'lib') {
    return;
  }

  ci.runAsync(
    '${dir.name} pck',
    (shell) => pck
        .buildLib(
          directory: dir,
          provider: _libs.contains(dir.name) || _modular.contains(dir.name),
        )
        .then((value) => value.forEach((element) => element.addToGit(shell))),
  );
}
