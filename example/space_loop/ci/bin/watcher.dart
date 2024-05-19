import 'dart:io';

import 'package:control_shell/future_block.dart';
import 'package:control_shell/shell.dart';
import 'assets.dart' as assets;
import 'pck.dart' as pck;

class BinWatcher {
  BinWatcher._();

  static bool _active = true;

  static bool get active => _active;

  static void pause() => _active = false;

  static void resume() => _active = true;

  FutureBlock? assetsBlocker;
  FutureBlock? libBlocker;

  void notifyAssets() {
    if (assetsBlocker == null) {
      assetsBlocker = FutureBlock()
        ..delayed(Duration(seconds: 1), () {
          assets.main([]);
          assetsBlocker = null;
        });
    } else {
      assetsBlocker!.postpone(Duration(seconds: 1));
    }
  }

  void notifyPck(Directory dir) {
    if (libBlocker == null) {
      libBlocker = FutureBlock()
        ..delayed(Duration(seconds: 1), () {
          pck.buildPck(dir);
          libBlocker = null;
        });
    } else {
      libBlocker!.postpone(Duration(seconds: 1));
    }
  }
}

void main(List<String> args) async {
  print('WATCHER PREPARE');

  final watcher = BinWatcher._();

  print('Watch: ${projectDir('assets')}');
  print('Watch: ${projectLib()}');

  projectDir('assets').watch(recursive: true).listen((event) {
    if (!BinWatcher.active) {
      return;
    }

    if (event.isDirectory) {
      return;
    }

    if (File(event.path).parent.name == 'localization') {
      return;
    }

    watcher.notifyAssets();
  });

  projectLib().watch(events: FileSystemEvent.create | FileSystemEvent.delete, recursive: true).listen((event) {
    if (!BinWatcher.active) {
      return;
    }

    if (event.isDirectory) {
      return;
    }

    if (File(event.path).name.startsWith(File(event.path).parent.name)) {
      return;
    }

    watcher.notifyPck(File(event.path).parent);
  });

  print('WATCHER STARTED');
}
