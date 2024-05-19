part of '../../loop.dart';

class Asset {
  const Asset._();

  static AssetFactory get instance => Control.get<AssetFactory>()!;

  static T get<T>(String asset) => instance._factory.get<T>(key: asset)!;
}

class AssetFactory implements Disposable {
  final _factory = Control.newFactory()..initialize();

  dynamic operator [](String asset) => _factory.get(key: asset);

  Future<Uint8List> _loadAsset(String path) async {
    final data = await rootBundle.load(path);
    return Uint8List.view(data.buffer);
  }

  Future<void> loadBinary<T>(String path, {String? name, Future<T> Function(Uint8List data)? converter}) async {
    final data = await _loadAsset(path).catchError((err) {
      printDebug(err);
      return Uint8List(0);
    });

    if (data.isEmpty) {
      return;
    }

    if (converter != null) {
      final object = await converter.call(data);

      _factory.set(key: name ?? path, value: object);
    } else {
      _factory.set(key: name ?? path, value: data);
    }
  }

  Future<void> loadImage(String path, {String? name}) => loadBinary(path, name: name, converter: (data) async {
        final codec = await ui.instantiateImageCodec(data);
        final frame = await codec.getNextFrame();

        return frame.image;
      });

  T? get<T>(String asset) => _factory.get<T>(key: asset);

  bool contains(String asset) => _factory.contains(asset);

  void remove(String asset) => _factory.remove(key: asset);

  void clear() => _factory.clear();

  void printFactoryContent() => _factory.printDebugStore(initializers: false);

  @override
  void dispose() {
    _factory.dispose();
  }
}

class AssetLoader {
  const AssetLoader._();

  static Future<void> load(
    AssetFactory factory, {
    Map<String, String> images = const {},
    Map<String, String> binary = const {},
    void Function(double value)? progress,
  }) async {
    final count = images.length + binary.length;
    int i = 0;

    for (final item in images.entries) {
      await factory.loadImage(item.value, name: item.key);

      progress?.call(++i / count);
    }

    for (final item in binary.entries) {
      await factory.loadImage(item.value, name: item.key);

      progress?.call(++i / count);
    }
  }
}
