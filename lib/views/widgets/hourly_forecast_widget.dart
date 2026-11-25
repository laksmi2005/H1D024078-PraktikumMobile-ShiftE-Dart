import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_code_mapper.dart';

class HourlyForecastWidget extends StatelessWidget {
  final List<HourlyForecastItem> hourlyForecast;

  const HourlyForecastWidget({
    super.key,
    required this.hourlyForecast,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyForecast.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Prakiraan Tiap Jam (24 Jam)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: hourlyForecast.length,
              separatorBuilder: (ctx, i) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = hourlyForecast[index];
                final isNow = index == 0;
                final condition = WeatherCodeMapper.getInfo(item.weatherCode);
                final timeLabel = isNow ? 'Sekarang' : DateFormat('HH:mm').format(item.time);

                return Container(
                  width: 68,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isNow
                        ? theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                        : (isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isNow
                          ? theme.colorScheme.primary.withValues(alpha: 0.5)
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                      width: isNow ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isNow ? FontWeight.bold : FontWeight.w500,
                          color: isNow
                              ? theme.colorScheme.primary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                      Icon(
                        condition.icon,
                        size: 24,
                        color: condition.gradientColors.first,
                      ),
                      if (item.precipitationProbability > 0)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.water_drop, size: 10, color: Colors.blue),
                            Text(
                              '${item.precipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox(height: 12),
                      Text(
                        '${item.temperature.toStringAsFixed(0)}°',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isNow ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
