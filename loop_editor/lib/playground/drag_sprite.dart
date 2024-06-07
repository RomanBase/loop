import 'dart:ui';

import 'package:loop/loop.dart';

class DragSprite extends Sprite with PointerComponent {
  DragSprite() : super(asset: Asset.get('placeholder'));

  Offset _dragOffset = Offset.zero;

  @override
  void onInit() {
    super.onInit();

    pointer.down = (event) => _dragOffset = Offset(event.position.dx - transform.position.x, event.position.dy - transform.position.y);
    pointer.move = (event) => transform.position = (event.position - _dragOffset).vector;
    pointer.up = (_) => _dragOffset = Offset.zero;
    pointer.cancel = (_) => _dragOffset = Offset.zero;

    getLoop()!.viewport.subscribe(() {
      size = Size(getLoop()!.size.width, 50.0);
    }).once();
  }
}
