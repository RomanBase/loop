part of '../../loop.dart';

class StaticMesh extends SceneActor {
  final Float32List vertices;
  final Float32List? uvs;
  final Uint16List? faces;

  StaticMesh(
    this.vertices, {
    this.uvs,
    this.faces,
  });

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
      ui.BlendMode.src,
      ui.Paint()..color = Colors.red,
    );

    canvas.restore();
  }
}
