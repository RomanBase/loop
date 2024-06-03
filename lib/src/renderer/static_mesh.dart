part of '../../loop.dart';

class StaticMesh extends SceneActor {
  final Float32List vertices;
  final Float32List? uvs;
  final Uint16List? faces;
  final ui.FragmentShader? shader;

  late final Paint _paint;

  StaticMesh(
    this.vertices, {
    this.uvs,
    this.faces,
    this.shader,
  }) {
    _paint = Paint()..shader = shader;
  }

  @override
  void render(Canvas canvas, Rect rect) {
    canvas.save();
    canvas.transform(screenMatrix.storage);

    canvas.drawVertices(
      ui.Vertices.raw(
        VertexMode.triangles,
        vertices,
        textureCoordinates: uvs,
        indices: faces,
      ),
      BlendMode.src,
      _paint,
    );

    canvas.restore();
  }
}
