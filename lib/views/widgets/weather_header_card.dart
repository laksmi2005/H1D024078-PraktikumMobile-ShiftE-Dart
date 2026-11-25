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

  @override
  Widget build(BuildContext context) {
    final condition = WeatherCodeMapper.getInfo(current.weatherCode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: condition.gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: condition.gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient icon
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.15,
              child: Icon(
                condition.icon,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Location selector & Favorite button
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onSearchTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 26,
                      ),
                      tooltip: isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
                    ),
                  ],
                ),

                if (location.admin1 != null || location.country != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 8),
                    child: Text(
                      [
                        if (location.admin1 != null && location.admin1!.isNotEmpty && location.admin1 != location.name)
                          location.admin1,
                        if (location.country != null) location.country,
                      ].join(', '),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // Temperature and Weather Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${current.temperature.toStringAsFixed(0)}°',
                          style: const TextStyle(
                            fontSize: 68,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            condition.description,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        condition.icon,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),

                // Bottom summary banner inside header card
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 16, color: Colors.white70),
                        Text(
                          todayDaily != null ? '${todayDaily!.maxTemperature.toStringAsFixed(0)}°' : '--',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.white70),
                        Text(
                          todayDaily != null ? '${todayDaily!.minTemperature.toStringAsFixed(0)}°' : '--',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (todayDaily != null && todayDaily!.maxPrecipitationProbability > 0)
                      Row(
                        children: [
                          const Icon(Icons.water_drop_outlined, size: 16, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            'Peluang Hujan: ${todayDaily!.maxPrecipitationProbability}%',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Angin: ${current.windSpeed.toStringAsFixed(0)} km/j',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
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
