import 'package:flutter/material.dart';
import '../../models/location_model.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_code_mapper.dart';

class WeatherHeaderCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;
  final DailyForecastItem? todayDaily;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onSearchTap;

  const WeatherHeaderCard({
    super.key,
    required this.location,
    required this.current,
    this.todayDaily,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onSearchTap,
  });

  IconData _getCloudIcon(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2) return Icons.cloud_queue_rounded;
    if (code >= 95) return Icons.flash_on_rounded;
    if (code >= 61) return Icons.beach_access_rounded;
    if (code >= 51) return Icons.grain_rounded;
    return Icons.cloud_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.getInfo(current.weatherCode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5BB8F5), Color(0xFF87CEEB)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(91, 184, 245, 0.35),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            bottom: 0,
            top: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Icon(
                _getCloudIcon(current.weatherCode),
                size: 130,
                color: Color.fromRGBO(255, 255, 255, 0.85),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onSearchTap,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 20),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleFavorite,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                if (location.admin1 != null || location.country != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 2, bottom: 4),
                    child: Text(
                      [
                        if (location.admin1 != null &&
                            location.admin1!.isNotEmpty &&
                            location.admin1 != location.name)
                          location.admin1,
                        if (location.country != null) location.country,
                      ].join(', '),
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  '${current.temperature.toStringAsFixed(0)}°',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    condition.description,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 14),
                Container(height: 0.5, color: Color.fromRGBO(255, 255, 255, 0.3)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 15, color: Colors.white70),
                    Text(
                      ' ${todayDaily?.maxTemperature.toStringAsFixed(0) ?? '--'}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_downward_rounded, size: 15, color: Colors.white70),
                    Text(
                      ' ${todayDaily?.minTemperature.toStringAsFixed(0) ?? '--'}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const Spacer(),
                    if (todayDaily != null && todayDaily!.maxPrecipitationProbability > 0) ...[
                      const Icon(Icons.water_drop_rounded, size: 14, color: Colors.white70),
                      Text(
                        ' ${todayDaily!.maxPrecipitationProbability}%',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.air_rounded, size: 14, color: Colors.white70),
                    Text(
                      ' ${current.windSpeed.toStringAsFixed(0)} km/j',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
