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
          colors: [Color(0xFF4A9ECC), Color(0xFF6BB8D4)],
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(74, 158, 204, 0.25),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -28,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 44,
            child: Icon(
              _getCloudIcon(current.weatherCode),
              size: 96,
              color: Colors.white.withValues(alpha: 0.90),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 15),
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
                            const Icon(Icons.location_on_rounded, color: Colors.white, size: 19),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                location.name,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 2),
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
                        color: isFavorite ? const Color(0xFFFF6B6B) : Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                if (location.admin1 != null || location.country != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 23, top: 1),
                    child: Text(
                      [
                        if (location.admin1 != null &&
                            location.admin1!.isNotEmpty &&
                            location.admin1 != location.name)
                          location.admin1,
                        if (location.country != null) location.country,
                      ].join(', '),
                      style: const TextStyle(fontSize: 12.5, color: Colors.white70),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${current.temperature.toStringAsFixed(0)}°',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        height: 0.95,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                condition.description,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Terasa ${current.apparentTemperature.toStringAsFixed(0)}° • Lembap ${current.relativeHumidity}%',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 90),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 0.5, color: Colors.white.withValues(alpha: 0.28)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 14, color: Colors.white70),
                    Text(
                      ' ${todayDaily?.maxTemperature.toStringAsFixed(0) ?? '--'}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white70),
                    Text(
                      ' ${todayDaily?.minTemperature.toStringAsFixed(0) ?? '--'}°',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                    ),
                    const Spacer(),
                    if (todayDaily != null && todayDaily!.maxPrecipitationProbability > 0) ...[
                      const Icon(Icons.water_drop_rounded, size: 13.5, color: Colors.white70),
                      Text(
                        ' ${todayDaily!.maxPrecipitationProbability}%',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.air_rounded, size: 13.5, color: Colors.white70),
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
