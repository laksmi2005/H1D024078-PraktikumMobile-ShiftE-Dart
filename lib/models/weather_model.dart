class CurrentWeather {
  final double temperature; // current.temperature_2m
  final int relativeHumidity; // current.relative_humidity_2m
  final double apparentTemperature; // current.apparent_temperature
  final double precipitation; // current.precipitation
  final int weatherCode; // current.weather_code
  final double windSpeed; // current.wind_speed_10m
  final String time;

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.time,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature: (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
      time: json['time'] ?? '',
    );
  }
}

class DailyForecastItem {
  final DateTime date;
  final int weatherCode;
  final double maxTemperature; // daily.temperature_2m_max
  final double minTemperature; // daily.temperature_2m_min
  final int maxPrecipitationProbability; // daily.precipitation_probability_max

  DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.maxPrecipitationProbability,
  });
}

class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecastItem> dailyForecast;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final List<DailyForecastItem> dailyList = [];
    final times = (dailyJson['time'] as List<dynamic>?) ?? [];
    final weatherCodes = (dailyJson['weather_code'] as List<dynamic>?) ?? [];
    final maxTemps = (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? [];
    final minTemps = (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? [];
    final precipProbs = (dailyJson['precipitation_probability_max'] as List<dynamic>?) ?? [];

    for (int i = 0; i < times.length; i++) {
      final dateStr = times[i].toString();
      final date = DateTime.tryParse(dateStr) ?? DateTime.now().add(Duration(days: i));
      dailyList.add(DailyForecastItem(
        date: date,
        weatherCode: i < weatherCodes.length ? (weatherCodes[i] as num).toInt() : 0,
        maxTemperature: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
        minTemperature: i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
        maxPrecipitationProbability: i < precipProbs.length ? (precipProbs[i] as num).toInt() : 0,
      ));
    }

    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'UTC',
      current: CurrentWeather.fromJson(currentJson),
      dailyForecast: dailyList,
    );
  }
}
