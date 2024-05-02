import 'package:ci/ci.dart' as ci;
import 'package:control_shell/ci/ci_git.dart' as git;
import 'package:control_shell/ci/ci_assets.dart';

void main(List<String> args) {
  ci.runAsync(
    'assets',
    (shell) => buildAssets(
      dir: 'resources',
      exclude: [
        'fonts',
        'localization',
      ],
    ).then((value) => git.addFile(shell, value)),
  );
}
