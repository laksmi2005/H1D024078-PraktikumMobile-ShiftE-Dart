import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

class LocalStorageService {
  static const String _keyFavorites = 'aire_favorites_v1';
  static const String _keySearchHistory = 'aire_search_history_v1';
  static const String _keyLastSelectedLocation = 'aire_last_location_v1';

  // Load favorite locations
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyFavorites) ?? '';
    return LocationModel.decodeList(jsonStr);
  }

  // Save favorite locations
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFavorites, LocationModel.encodeList(favorites));
  }

  // Load search history
  Future<List<LocationModel>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySearchHistory) ?? '';
    return LocationModel.decodeList(jsonStr);
  }

  // Save search history (keep max 10 items)
  Future<void> saveSearchHistory(List<LocationModel> history) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = history.take(10).toList();
    await prefs.setString(_keySearchHistory, LocationModel.encodeList(trimmed));
  }

  // Load last selected location
  Future<LocationModel?> getLastSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyLastSelectedLocation);
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final list = LocationModel.decodeList('[$jsonStr]');
      return list.isNotEmpty ? list.first : null;
    } catch (_) {
      return null;
    }
  }

  // Save last selected location
  Future<void> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSelectedLocation, LocationModel.encodeList([location]).replaceAll(RegExp(r'^\[|\]$'), ''));
  }
}
