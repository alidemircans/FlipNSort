enum StoreEnum { appleStore, googlePlay, amazonAppstore }

class StoreConfig {
  final StoreEnum store;
  final String apiKey;
  static StoreConfig? _instance;

  factory StoreConfig({required StoreEnum store, required String apiKey}) {
    _instance ??= StoreConfig._internal(store, apiKey);
    return _instance!;
  }

  StoreConfig._internal(this.store, this.apiKey);

  static StoreConfig get instance {
    return _instance!;
  }

  static bool isForAppleStore() => instance.store == StoreEnum.appleStore;

  static bool isForGooglePlay() => instance.store == StoreEnum.googlePlay;
}