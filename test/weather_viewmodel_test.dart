import 'package:flutter_test/flutter_test.dart';
import 'package:aire/models/location_model.dart';
import 'package:aire/models/weather_model.dart';
import 'package:aire/utils/weather_code_mapper.dart';

void main() {
  group('LocationModel tests', () {
    test('LocationModel json serialization and equality', () {
      final loc = LocationModel(
        id: 1,
        name: 'Bandung',
        latitude: -6.9175,
        longitude: 107.6191,
        country: 'Indonesia',
        admin1: 'West Java',
      );

      final json = loc.toJson();
      final fromJson = LocationModel.fromJson(json);

      expect(fromJson.name, 'Bandung');
      expect(fromJson.latitude, -6.9175);
      expect(fromJson.displayName, 'Bandung, West Java, Indonesia');
      expect(loc == fromJson, isTrue);
    });

    test('Encode and decode list of locations', () {
      final list = [
        LocationModel(id: 1, name: 'Jakarta', latitude: -6.2, longitude: 106.8),
        LocationModel(id: 2, name: 'Surabaya', latitude: -7.2, longitude: 112.7),
      ];

      final encoded = LocationModel.encodeList(list);
      final decoded = LocationModel.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded.first.name, 'Jakarta');
      expect(decoded.last.name, 'Surabaya');
    });
  });

  group('WeatherData parsing tests', () {
    test('WeatherData from Open-Meteo json mock', () {
      final sampleJson = {
        'latitude': -6.2,
        'longitude': 106.8,
        'timezone': 'Asia/Jakarta',
        'current': {
          'temperature_2m': 29.5,
          'relative_humidity_2m': 80,
          'apparent_temperature': 33.2,
          'precipitation': 1.5,
          'weather_code': 61,
          'wind_speed_10m': 12.4,
          'time': '2026-11-25T14:00',
        },
        'daily': {
          'time': ['2026-11-25', '2026-11-26'],
          'weather_code': [61, 3],
          'temperature_2m_max': [32.0, 31.0],
          'temperature_2m_min': [24.0, 23.5],
          'precipitation_probability_max': [75, 40],
        }
      };

      final data = WeatherData.fromJson(sampleJson);

      expect(data.latitude, -6.2);
      expect(data.current.temperature, 29.5);
      expect(data.current.relativeHumidity, 80);
      expect(data.current.apparentTemperature, 33.2);
      expect(data.current.precipitation, 1.5);
      expect(data.current.weatherCode, 61);
      expect(data.current.windSpeed, 12.4);
      expect(data.dailyForecast.length, 2);
      expect(data.dailyForecast.first.maxPrecipitationProbability, 75);
    });
  });

  group('WeatherCodeMapper tests', () {
    test('Maps weather codes accurately', () {
      final sunny = WeatherCodeMapper.getInfo(0);
      expect(sunny.description, contains('Cerah'));

      final rain = WeatherCodeMapper.getInfo(61);
      expect(rain.description, contains('Hujan'));

      final thunder = WeatherCodeMapper.getInfo(95);
      expect(thunder.description, contains('Petir'));
    });
  });
}
