part of '../../loop.dart';

class BigMeshSolver extends SceneActor {
  late Float32List vertices;
  late Float32List uvs;
  late Uint16List faces;
  final ui.FragmentShader? shader;

  late final Paint _paint;

  BigMeshSolver({
    this.shader,
    Size? size,
  }) {
    this.size = size ?? const Size(1.0, 1.0);
    _paint = Paint()..shader = shader;
  }

  

  @override
  void renderComponent(Canvas canvas, Rect rect) {
    // TODO: implement renderComponent
  }
}
