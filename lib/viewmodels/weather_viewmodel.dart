import 'package:flutter/foundation.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_api_service.dart';
import '../services/local_storage_service.dart';

enum ViewState { initial, loading, success, error, empty }

class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    WeatherApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? WeatherApiService(),
        _storageService = storageService ?? LocalStorageService();

  // State
  LocationModel? _currentLocation;
  WeatherData? _weatherData;
  ViewState _weatherState = ViewState.initial;
  String _weatherError = '';

  List<LocationModel> _searchResults = [];
  ViewState _searchState = ViewState.initial;
  String _searchError = '';

  List<LocationModel> _favorites = [];
  List<LocationModel> _searchHistory = [];

  // Getters
  LocationModel? get currentLocation => _currentLocation;
  WeatherData? get weatherData => _weatherData;
  ViewState get weatherState => _weatherState;
  String get weatherError => _weatherError;

  List<LocationModel> get searchResults => _searchResults;
  ViewState get searchState => _searchState;
  String get searchError => _searchError;

  List<LocationModel> get favorites => _favorites;
  List<LocationModel> get searchHistory => _searchHistory;

  bool get isLoadingWeather => _weatherState == ViewState.loading;
  bool get isSearching => _searchState == ViewState.loading;

  bool isFavorite(LocationModel? loc) {
    if (loc == null) return false;
    return _favorites.any((f) =>
        f.name.toLowerCase() == loc.name.toLowerCase() &&
        (f.latitude - loc.latitude).abs() < 0.01 &&
        (f.longitude - loc.longitude).abs() < 0.01);
  }

  /// Initialize viewmodel by loading storage and initial weather
  Future<void> init() async {
    await Future.wait([
      _loadFavorites(),
      _loadSearchHistory(),
    ]);

    // Check last location or default to Jakarta
    final lastLoc = await _storageService.getLastSelectedLocation();
    final defaultLocation = lastLoc ??
        LocationModel(
          id: 1642911,
          name: 'Jakarta',
          latitude: -6.2146,
          longitude: 106.8451,
          country: 'Indonesia',
          admin1: 'Jakarta',
        );

    await selectLocation(defaultLocation, saveToHistory: false);
  }

  Future<void> _loadFavorites() async {
    try {
      _favorites = await _storageService.getFavorites();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadSearchHistory() async {
    try {
      _searchHistory = await _storageService.getSearchHistory();
      notifyListeners();
    } catch (_) {}
  }

  /// Select location and fetch weather
  Future<void> selectLocation(LocationModel location, {bool saveToHistory = true}) async {
    _currentLocation = location;
    await _storageService.saveLastSelectedLocation(location);

    if (saveToHistory) {
      _addToHistory(location);
    }

    await fetchWeather();
  }

  /// Fetch weather for current location
  Future<void> fetchWeather() async {
    if (_currentLocation == null) return;

    _weatherState = ViewState.loading;
    _weatherError = '';
    notifyListeners();

    try {
      final data = await _apiService.getWeather(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      _weatherData = data;
      _weatherState = ViewState.success;
    } catch (e) {
      _weatherError = e.toString().replaceFirst('Exception: ', '');
      _weatherState = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  /// Search cities via Geocoding API
  Future<void> searchCities(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _searchState = ViewState.initial;
      _searchError = '';
      notifyListeners();
      return;
    }

    _searchState = ViewState.loading;
    _searchError = '';
    notifyListeners();

    try {
      final results = await _apiService.searchLocations(trimmed);
      _searchResults = results;
      _searchState = results.isEmpty ? ViewState.empty : ViewState.success;
    } catch (e) {
      _searchError = e.toString().replaceFirst('Exception: ', '');
      _searchState = ViewState.error;
    } finally {
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    _searchState = ViewState.initial;
    _searchError = '';
    notifyListeners();
  }

  /// Toggle favorite location
  Future<void> toggleFavorite(LocationModel location) async {
    final index = _favorites.indexWhere((f) =>
        f.name.toLowerCase() == location.name.toLowerCase() &&
        (f.latitude - location.latitude).abs() < 0.01 &&
        (f.longitude - location.longitude).abs() < 0.01);

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.insert(0, location);
    }

    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  void _addToHistory(LocationModel location) {
    _searchHistory.removeWhere((item) =>
        item.name.toLowerCase() == location.name.toLowerCase() &&
        (item.latitude - location.latitude).abs() < 0.01);
    _searchHistory.insert(0, location);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.take(10).toList();
    }
    _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> removeFromHistory(LocationModel location) async {
    _searchHistory.removeWhere((item) =>
        item.name.toLowerCase() == location.name.toLowerCase() &&
        (item.latitude - location.latitude).abs() < 0.01);
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _searchHistory = [];
    await _storageService.saveSearchHistory(_searchHistory);
    notifyListeners();
  }
}
