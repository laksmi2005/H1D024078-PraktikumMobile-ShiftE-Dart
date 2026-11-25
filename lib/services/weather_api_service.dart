import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/location_model.dart';
import '../models/weather_model.dart';

class WeatherApiService {
  static const String _forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String _geocodingBaseUrl = 'https://geocoding-api.open-meteo.com/v1/search';

  final http.Client _client;

  WeatherApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Search locations by city name using Open-Meteo Geocoding API
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final url = Uri.parse(
      '$_geocodingBaseUrl?name=${Uri.encodeComponent(trimmed)}&count=10&language=id&format=json',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Gagal memuat hasil pencarian (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak dapat terhubung ke internet. Periksa koneksi Anda.');
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Terjadi kesalahan saat mencari kota: $e');
    }
  }

  /// Get weather forecast from Open-Meteo Weather Forecast API
  Future<WeatherData> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final url = Uri.parse(
      '$_forecastBaseUrl?'
      'latitude=$latitude&'
      'longitude=$longitude&'
      'current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&'
      'daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max&'
      'timezone=auto',
    );

    try {
      final response = await _client.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(data);
      } else {
        throw HttpException('Gagal mengambil data cuaca (Status: ${response.statusCode})');
      }
    } on SocketException {
      throw const SocketException('Tidak dapat terhubung ke internet. Periksa koneksi Anda.');
    } catch (e) {
      if (e is SocketException || e is HttpException) rethrow;
      throw Exception('Gagal memuat data cuaca: $e');
    }
  }
}
