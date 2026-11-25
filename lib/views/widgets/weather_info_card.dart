import 'package:flutter/material.dart';

class WeatherInfoGrid extends StatelessWidget {
  final double currentTemperature;
  final double apparentTemperature;
  final int relativeHumidity;
  final double windSpeed;
  final double precipitation;
  final int precipitationProbability;
  final double maxTemperature;
  final double minTemperature;
  final int weatherCode;

  const WeatherInfoGrid({
    super.key,
    required this.currentTemperature,
    required this.apparentTemperature,
    required this.relativeHumidity,
    required this.windSpeed,
    required this.precipitation,
    required this.precipitationProbability,
    required this.maxTemperature,
    required this.minTemperature,
    required this.weatherCode,
  });

  String _getInsightTip() {
    if (weatherCode >= 95) {
      return '⚡ Badai petir diprediksi. Hindari tempat terbuka!';
    } else if (weatherCode >= 51 || precipitationProbability >= 70) {
      return '☔ Peluang hujan tinggi. Siapkan payung hari ini.';
    } else if (currentTemperature >= 33) {
      return '☀️ Cuaca terik. Jaga cairan dan pakai tabir surya.';
    } else if (windSpeed >= 25) {
      return '💨 Angin cukup kencang. Hati-hati saat berkendara.';
    } else {
      return '🌤️ Cuaca nyaman untuk aktivitas luar ruangan hari ini.';
    }
  }

  String _getHumidityStatus(int h) {
    if (h < 40) return 'Kering';
    if (h <= 70) return 'Nyaman';
    return 'Lembap';
  }

  String _getWindStatus(double s) {
    if (s < 5) return 'Tenang';
    if (s < 20) return 'Sepoi-sepoi';
    if (s < 40) return 'Sedang';
    return 'Kencang';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tempDiff = apparentTemperature - currentTemperature;
    final tempDiffStr = tempDiff.abs() < 0.5
        ? 'Sama dengan suhu riil'
        : (tempDiff > 0
            ? 'Terasa ${tempDiff.toStringAsFixed(1)}° lebih hangat'
            : 'Terasa ${tempDiff.abs().toStringAsFixed(1)}° lebih sejuk');

    final metricsBg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Insight Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : theme.colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            _getInsightTip(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Detail Cuaca Hari Ini',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        // 2x3 Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: [
            _MetricTile(
              icon: Icons.thermostat_rounded,
              label: 'Terasa Seperti',
              value: '${apparentTemperature.toStringAsFixed(1)}°C',
              sub: tempDiffStr,
              accentColor: const Color(0xFFF97316),
              bgColor: metricsBg,
              isDark: isDark,
            ),
            _MetricTile(
              icon: Icons.water_drop_rounded,
              label: 'Kelembapan',
              value: '$relativeHumidity%',
              sub: _getHumidityStatus(relativeHumidity),
              accentColor: const Color(0xFF38BDF8),
              bgColor: metricsBg,
              isDark: isDark,
            ),
            _MetricTile(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${windSpeed.toStringAsFixed(1)} km/j',
              sub: _getWindStatus(windSpeed),
              accentColor: const Color(0xFF2DD4BF),
              bgColor: metricsBg,
              isDark: isDark,
            ),
            _MetricTile(
              icon: Icons.grain_rounded,
              label: 'Curah Hujan',
              value: '${precipitation.toStringAsFixed(1)} mm',
              sub: 'Peluang $precipitationProbability%',
              accentColor: const Color(0xFF818CF8),
              bgColor: metricsBg,
              isDark: isDark,
            ),
            _MetricTile(
              icon: Icons.arrow_upward_rounded,
              label: 'Suhu Maks.',
              value: '${maxTemperature.toStringAsFixed(0)}°C',
              sub: 'Puncak siang hari',
              accentColor: const Color(0xFFF43F5E),
              bgColor: metricsBg,
              isDark: isDark,
            ),
            _MetricTile(
              icon: Icons.arrow_downward_rounded,
              label: 'Suhu Min.',
              value: '${minTemperature.toStringAsFixed(0)}°C',
              sub: 'Terendah malam ini',
              accentColor: const Color(0xFF06B6D4),
              bgColor: metricsBg,
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accentColor;
  final Color bgColor;
  final bool isDark;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
    required this.bgColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: accentColor),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.3),
          ),
          Text(
            sub,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
