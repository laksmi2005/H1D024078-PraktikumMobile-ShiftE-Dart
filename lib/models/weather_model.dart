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

class HourlyForecastItem {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;

  HourlyForecastItem({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
  });
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
  final List<HourlyForecastItem> hourlyForecast;
  final List<DailyForecastItem> dailyForecast;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.hourlyForecast,
    required this.dailyForecast,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final hourlyJson = json['hourly'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    // Parse Hourly (take next 24 hours around current time)
    final List<HourlyForecastItem> hourlyList = [];
    final hTimes = (hourlyJson['time'] as List<dynamic>?) ?? [];
    final hTemps = (hourlyJson['temperature_2m'] as List<dynamic>?) ?? [];
    final hCodes = (hourlyJson['weather_code'] as List<dynamic>?) ?? [];
    final hProbs = (hourlyJson['precipitation_probability'] as List<dynamic>?) ?? [];

    final now = DateTime.now();
    int startIndex = 0;
    for (int i = 0; i < hTimes.length; i++) {
      final parsed = DateTime.tryParse(hTimes[i].toString());
      if (parsed != null && parsed.isAfter(now.subtract(const Duration(hours: 1)))) {
        startIndex = i;
        break;
      }
    }

    final endIndex = (startIndex + 24).clamp(0, hTimes.length);
    for (int i = startIndex; i < endIndex; i++) {
      final time = DateTime.tryParse(hTimes[i].toString()) ?? now.add(Duration(hours: i - startIndex));
      hourlyList.add(HourlyForecastItem(
        time: time,
        temperature: i < hTemps.length ? (hTemps[i] as num).toDouble() : 0.0,
        weatherCode: i < hCodes.length ? (hCodes[i] as num).toInt() : 0,
        precipitationProbability: i < hProbs.length ? (hProbs[i] as num).toInt() : 0,
      ));
    }

    // Parse Daily
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
      hourlyForecast: hourlyList,
      dailyForecast: dailyList,
    );
  }
}
