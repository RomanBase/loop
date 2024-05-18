import 'package:loop/loop.dart';

class DragSprite extends Sprite with PointerComponent {
  DragSprite() : super(asset: Asset.get('placeholder'));

  @override
  void onInit() {
    super.onInit();

    pointer.move = (event) => transform.position = event.localPosition;

    getLoop()!.frame.subscribe((value) {
      transform.position = value.center;
    }, current: false).once();
  }
}
