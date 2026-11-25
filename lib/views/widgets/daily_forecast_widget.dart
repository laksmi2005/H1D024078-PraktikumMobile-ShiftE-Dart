import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/weather_model.dart';
import '../../utils/weather_code_mapper.dart';

class DailyForecastWidget extends StatelessWidget {
  final List<DailyForecastItem> dailyForecast;

  const DailyForecastWidget({
    super.key,
    required this.dailyForecast,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyForecast.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Calculate global min and max for temperature range bar
    double globalMin = dailyForecast.first.minTemperature;
    double globalMax = dailyForecast.first.maxTemperature;
    for (final item in dailyForecast) {
      if (item.minTemperature < globalMin) globalMin = item.minTemperature;
      if (item.maxTemperature > globalMax) globalMax = item.maxTemperature;
    }
    final range = (globalMax - globalMin).clamp(1.0, 50.0);

    return Container(
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Prakiraan Cuaca 7 Hari ke Depan',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            separatorBuilder: (ctx, i) => const Divider(height: 16, thickness: 0.5),
            itemBuilder: (context, index) {
              final item = dailyForecast[index];
              final condition = WeatherCodeMapper.getInfo(item.weatherCode);

              // Date formatting
              String dayName;
              if (index == 0) {
                dayName = 'Hari Ini';
              } else if (index == 1) {
                dayName = 'Besok';
              } else {
                dayName = DateFormat('EEEE', 'id_ID').format(item.date);
              }
              final dateFormatted = DateFormat('d MMM', 'id_ID').format(item.date);

              // Calculate start and width percentage for temp bar
              final leftPercent = ((item.minTemperature - globalMin) / range).clamp(0.0, 1.0);
              final rightPercent = ((item.maxTemperature - globalMin) / range).clamp(0.0, 1.0);
              final barWidthPercent = (rightPercent - leftPercent).clamp(0.15, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    // Day & Date
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dayName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            dateFormatted,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Condition Icon & Rain badge
                    SizedBox(
                      width: 52,
                      child: Row(
                        children: [
                          Icon(
                            condition.icon,
                            color: condition.gradientColors.first,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          if (item.maxPrecipitationProbability > 0)
                            Text(
                              '${item.maxPrecipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Min Temp
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.minTemperature.toStringAsFixed(0)}°',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Dynamic Temperature Bar (Apple Weather style)
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalWidth = constraints.maxWidth;
                          final barLeft = totalWidth * leftPercent;
                          final barWidth = (totalWidth * barWidthPercent).clamp(12.0, totalWidth - barLeft);

                          return Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: barLeft,
                                  width: barWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF38BDF8), Color(0xFFF59E0B), Color(0xFFEF4444)],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Max Temp
                    SizedBox(
                      width: 28,
                      child: Text(
                        '${item.maxTemperature.toStringAsFixed(0)}°',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
