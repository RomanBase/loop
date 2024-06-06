import 'dart:ui';

import 'package:loop/loop.dart';

class DragSprite extends Sprite with PointerComponent {
  DragSprite() : super(asset: Asset.get('placeholder'));

  @override
  void onInit() {
    super.onInit();

    pointer.move = (event) => transform.position = event.position.vector;

    getLoop()!.viewport.subscribe(() {
      //transform.position = getLoop()!.size.center(Offset.zero);
      size = Size(getLoop()!.size.width, 50.0);
    }).once();
  }
}
