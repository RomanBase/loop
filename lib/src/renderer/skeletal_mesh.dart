part of '../../loop.dart';

class SkeletalMesh extends SceneActor {
  final Float32List vertices;
  final Float32List? uvs;
  final Uint16List? faces;
  final ui.FragmentShader? shader;

  late final Float32List dynamicVertices;
  late final Paint _paint;

  SkeletalMesh(
    this.vertices, {
    this.uvs,
    this.faces,
    this.shader,
    Size? size,
  }) {
    dynamicVertices = Float32List.fromList(vertices);
    this.size = size ?? getVerticesBounds();
    _paint = Paint()..shader = shader;
  }

  Size getVerticesBounds() {
    final vertices = dynamicVertices;

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

  //TODO: bones interpolation and skeletal animation :)
  void updateFrame(List<dynamic> bones) {}

  @override
  void render(Canvas canvas, Rect rect) {
    canvas.save();
    canvas.transform(screenMatrix.storage);

    canvas.drawVertices(
      ui.Vertices.raw(
        VertexMode.triangles,
        dynamicVertices,
        textureCoordinates: uvs,
        indices: faces,
      ),
      BlendMode.src,
      _paint,
    );

    canvas.restore();
  }
}
