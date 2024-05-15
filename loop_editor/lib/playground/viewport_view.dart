import 'package:flutter_control/control.dart';
import 'package:loop/loop.dart';
import 'dart:math' as math;

class ViewportView extends ControllableWidget<LoopScene> {
  const ViewportView({
    super.key,
    required super.control,
  });

  @override
  Widget build(CoreElement context) {
    const step = 50.0;

    return Container(
      width: 320.0,
      color: Colors.black38,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => control.viewport.position = -Offset(control.size.width * 0.5, control.size.height * 0.5),
                icon: const Icon(Icons.center_focus_strong),
              ),
              IconButton(
                onPressed: () => control.viewport.position += const Offset(0.0, -step),
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                onPressed: () => control.viewport.position += const Offset(0.0, step),
                icon: const Icon(Icons.arrow_downward),
              ),
              IconButton(
                onPressed: () => control.viewport.position += const Offset(-step, 0.0),
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: () => control.viewport.position += const Offset(step, 0.0),
                icon: const Icon(Icons.arrow_forward),
              ),
              IconButton(
                onPressed: () => control.viewport.rotation += math.pi * 0.25,
                icon: const Icon(Icons.rotate_90_degrees_ccw),
              ),
              IconButton(
                onPressed: () => control.viewport.rotation += -math.pi * 0.25,
                icon: const Icon(Icons.rotate_90_degrees_cw),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  '[${control.size.width.toInt()}, ${control.size.height.toInt()}]',
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  '[${control.viewport.position.dx.toInt()}, ${control.viewport.position.dy.toInt()}] (${control.viewport.rotation * 180.0 ~/ math.pi})',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}