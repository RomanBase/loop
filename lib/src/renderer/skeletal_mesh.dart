part of '../../loop.dart';

class SkeletalMesh extends StaticMesh {
  late final Float32List dynamicVertices;

  SkeletalMesh(
    super.vertices, {
    super.uvs,
    super.faces,
    super.shader,
    Size? size,
  }) {
    dynamicVertices = Float32List.fromList(vertices);
  }

  //TODO: bones interpolation and skeletal animation :)
  void updateFrame(List<dynamic> bones) {}

  @override
  void renderComponent(Canvas canvas, Rect rect) {
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
  }
}
