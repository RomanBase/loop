import 'package:ci/ci.dart' as ci;
import 'package:control_shell/ci/ci_localino.dart' as localino;

void main(List<String> args) async {
  await ci.runAsync(
    'localization',
    (shell) => localino.fetchLocalizations(
      shell,
      space: '',
      project: '',
      access: '',
    ),
  );

  await ci.runAsync(
    'localino resources',
    (shell) => localino.buildResourceProvider(
      dir: 'resources',
    ),
  );
}
