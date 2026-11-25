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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, isDark ? 0.2 : 0.05),
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 10),
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

              return Row(
                children: [
                  // Day & Date
                  SizedBox(
                    width: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dayName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(dateFormatted,
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey[500] : Colors.grey[500])),
                      ],
                    ),
                  ),

                  // Icon + Rain %
                  SizedBox(
                    width: 52,
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
                                color: Color(0xFF38BDF8)),
                          ),
                        ],
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
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[400] : Colors.grey[500]),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Full-width gradient bar (cyan → yellow → orange → red)
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF38BDF8), // cyan
                            Color(0xFF34D399), // green
                            Color(0xFFFBBF24), // yellow
                            Color(0xFFF97316), // orange
                            Color(0xFFEF4444), // red
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Max Temp
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${item.maxTemperature.toStringAsFixed(0)}°',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
