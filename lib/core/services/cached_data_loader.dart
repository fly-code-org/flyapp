import 'package:flutter/foundation.dart';
import 'cache_service.dart';

enum LoadingState {
  initial,
  loadingFromCache,
  loadedFromCache,
  loadingFresh,
  loadedFresh,
  error,
}

class CachedDataState<T> {
  final T? data;
  final LoadingState state;
  final String? error;
  final bool isFromCache;

  const CachedDataState({
    this.data,
    this.state = LoadingState.initial,
    this.error,
    this.isFromCache = false,
  });

  bool get isLoading =>
      state == LoadingState.initial ||
      state == LoadingState.loadingFromCache ||
      state == LoadingState.loadingFresh;

  bool get hasData => data != null;

  bool get hasError => state == LoadingState.error;

  bool get showSkeleton => !hasData && isLoading;

  bool get isRefreshing =>
      hasData && state == LoadingState.loadingFresh;

  CachedDataState<T> copyWith({
    T? data,
    LoadingState? state,
    String? error,
    bool? isFromCache,
  }) {
    return CachedDataState<T>(
      data: data ?? this.data,
      state: state ?? this.state,
      error: error,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

class CachedDataLoader<T> extends ChangeNotifier {
  final String cacheKey;
  final Future<T> Function() fetchData;
  final T Function(dynamic json) fromJson;
  final dynamic Function(T data) toJson;
  final Duration? maxAge;
  final bool fetchFreshInBackground;

  CachedDataState<T> _state = const CachedDataState();
  CachedDataState<T> get state => _state;

  CacheService? _cacheService;

  CachedDataLoader({
    required this.cacheKey,
    required this.fetchData,
    required this.fromJson,
    required this.toJson,
    this.maxAge = const Duration(hours: 1),
    this.fetchFreshInBackground = true,
  });

  Future<void> load({bool forceRefresh = false}) async {
    _state = _state.copyWith(state: LoadingState.loadingFromCache);
    notifyListeners();

    _cacheService ??= await CacheService.getInstance();

    if (!forceRefresh) {
      final cached = _cacheService!.get<T>(cacheKey, fromJson: fromJson);

      if (cached != null && !cached.isExpired) {
        _state = CachedDataState<T>(
          data: cached.data,
          state: cached.isStale
              ? LoadingState.loadingFresh
              : LoadingState.loadedFromCache,
          isFromCache: true,
        );
        notifyListeners();

        if (cached.isStale && fetchFreshInBackground) {
          _fetchFreshData();
        }
        return;
      }
    }

    await _fetchFreshData();
  }

  Future<void> _fetchFreshData() async {
    _state = _state.copyWith(state: LoadingState.loadingFresh);
    notifyListeners();

    try {
      final data = await fetchData();

      await _cacheService?.set<T>(
        cacheKey,
        data,
        maxAge: maxAge,
        toJson: toJson,
      );

      _state = CachedDataState<T>(
        data: data,
        state: LoadingState.loadedFresh,
        isFromCache: false,
      );
      notifyListeners();
    } catch (e) {
      if (_state.hasData) {
        _state = _state.copyWith(
          state: LoadingState.error,
          error: e.toString(),
        );
      } else {
        _state = CachedDataState<T>(
          state: LoadingState.error,
          error: e.toString(),
        );
      }
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> clearCache() async {
    _cacheService ??= await CacheService.getInstance();
    await _cacheService!.remove(cacheKey);
  }

  void updateData(T data) {
    _state = CachedDataState<T>(
      data: data,
      state: LoadingState.loadedFresh,
      isFromCache: false,
    );
    notifyListeners();

    _cacheService?.set<T>(
      cacheKey,
      data,
      maxAge: maxAge,
      toJson: toJson,
    );
  }
}
