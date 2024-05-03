part of '../../loop.dart';

class Asset {
  const Asset._();

  static AssetFactory get _instance => Control.get<AssetFactory>()!;

  static T get<T>(String asset) => _instance.factory.get<T>(key: asset)!;
}

class AssetFactory {
  final factory = Control.newFactory()..initialize();

  Future<Uint8List> loadAsset(String path, {String? name}) async {
    final data = await rootBundle.load(path);
    return Uint8List.view(data.buffer);
  }

  Future<void> loadImage(String path, {String? name}) async {
    final data = await loadAsset(path);
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();

    factory.set(key: name ?? path, value: frame.image);
  }

  void remove(String asset) => factory.remove(key: asset);
}
