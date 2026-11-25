import 'package:flutter/material.dart';

class WeatherMetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const WeatherMetricItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (iconColor ?? theme.colorScheme.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: iconColor ?? theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInfoGrid extends StatelessWidget {
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final double maxTemperature;
  final double minTemperature;

  const WeatherInfoGrid({
    super.key,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.maxTemperature,
    required this.minTemperature,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Detail Cuaca Hari Ini',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.1,
          children: [
            WeatherMetricItem(
              icon: Icons.thermostat_rounded,
              label: 'Terasa Seperti',
              value: '${apparentTemperature.toStringAsFixed(1)}°C',
              iconColor: Colors.orange,
            ),
            WeatherMetricItem(
              icon: Icons.water_drop_rounded,
              label: 'Kelembapan',
              value: '$relativeHumidity%',
              iconColor: Colors.blueAccent,
            ),
            WeatherMetricItem(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${windSpeed.toStringAsFixed(1)} km/j',
              iconColor: Colors.teal,
            ),
            WeatherMetricItem(
              icon: Icons.grain_rounded,
              label: 'Curah Hujan',
              value: '${precipitation.toStringAsFixed(1)} mm',
              iconColor: Colors.indigoAccent,
            ),
            WeatherMetricItem(
              icon: Icons.arrow_upward_rounded,
              label: 'Suhu Maksimum',
              value: '${maxTemperature.toStringAsFixed(1)}°C',
              iconColor: Colors.redAccent,
            ),
            WeatherMetricItem(
              icon: Icons.arrow_downward_rounded,
              label: 'Suhu Minimum',
              value: '${minTemperature.toStringAsFixed(1)}°C',
              iconColor: Colors.cyan,
            ),
          ],
        ),
      ],
    );
  }
}
