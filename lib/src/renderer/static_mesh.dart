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
    Size? size,
  }) {
    this.size = size ?? getVerticesBounds();
    _paint = Paint()..shader = shader;
  }

  Size getVerticesBounds() {
    double minX = vertices[0], maxX = vertices[0];
    double minY = vertices[1], maxY = vertices[1];

    for (int i = 2; i < vertices.length; i += 2) {
      if (vertices[i] < minX) {
        minX = vertices[i];
      } else if (vertices[i] > maxX) {
        maxX = vertices[i];
      }

      if (vertices[i + 1] < minY) {
        minY = vertices[i + 1];
      } else if (vertices[i + 1] > maxY) {
        maxY = vertices[i + 1];
      }
    }

    return Size((maxX - minX).abs(), (maxY - minY).abs());
  }

  @override
  void renderComponent(Canvas canvas, Rect rect) {
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
  }
}
