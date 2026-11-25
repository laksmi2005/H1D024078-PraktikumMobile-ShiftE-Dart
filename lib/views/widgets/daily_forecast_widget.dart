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

    // Global range for relative bar sizing
    double globalMin = dailyForecast.map((e) => e.minTemperature).reduce((a, b) => a < b ? a : b);
    double globalMax = dailyForecast.map((e) => e.maxTemperature).reduce((a, b) => a > b ? a : b);
    final range = (globalMax - globalMin).clamp(1.0, 50.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
              Icon(Icons.calendar_month_rounded, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Prakiraan 7 Hari ke Depan',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            itemBuilder: (context, index) {
              final item = dailyForecast[index];
              final condition = WeatherCodeMapper.getInfo(item.weatherCode);

              String dayName;
              if (index == 0) {
                dayName = 'Hari Ini';
              } else if (index == 1) {
                dayName = 'Besok';
              } else {
                dayName = DateFormat('EEE', 'id_ID').format(item.date);
              }
              final dateFormatted = DateFormat('d MMM', 'id_ID').format(item.date);

              final leftFraction = ((item.minTemperature - globalMin) / range).clamp(0.0, 1.0);
              final rightFraction = ((item.maxTemperature - globalMin) / range).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Row(
                  children: [
                    // Day & Date
                    SizedBox(
                      width: 68,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dayName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              )),
                          Text(dateFormatted,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                                fontSize: 11,
                              )),
                        ],
                      ),
                    ),

                    // Icon + Rain %
                    SizedBox(
                      width: 48,
                      child: Row(
                        children: [
                          Icon(condition.icon, size: 20, color: condition.gradientColors.first),
                          if (item.maxPrecipitationProbability > 0) ...[
                            const SizedBox(width: 2),
                            Text(
                              '${item.maxPrecipitationProbability}%',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Min Temp
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.minTemperature.toStringAsFixed(0)}°',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[500],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Relative Temp Bar
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalW = constraints.maxWidth;
                          final barLeft = totalW * leftFraction;
                          final barRight = totalW * rightFraction;
                          final barW = (barRight - barLeft).clamp(14.0, totalW);
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              // Track
                              Container(
                                height: 5,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              // Active bar
                              Positioned(
                                left: barLeft,
                                child: Container(
                                  height: 5,
                                  width: barW,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(3),
                                    gradient: LinearGradient(
                                      colors: [
                                        condition.gradientColors.last.withValues(alpha: 0.6),
                                        condition.gradientColors.first,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Max Temp
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.maxTemperature.toStringAsFixed(0)}°',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
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
