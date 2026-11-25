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
    if (weatherCode >= 95) return '⚡ Badai petir diprediksi. Hindari tempat terbuka!';
    if (weatherCode >= 51 || precipitationProbability >= 70) return '☔ Peluang hujan tinggi. Siapkan payung hari ini.';
    if (currentTemperature >= 33) return '☀️ Cuaca terik. Jaga cairan tubuh dan pakai tabir surya.';
    if (windSpeed >= 25) return '💨 Angin cukup kencang. Hati-hati saat berkendara.';
    return '🌤️ Cuaca nyaman untuk aktivitas luar ruangan hari ini.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tempDiff = apparentTemperature - currentTemperature;
    final tempDiffStr = tempDiff.abs() < 0.5
        ? 'Sama dengan suhu riil'
        : (tempDiff > 0
            ? '${tempDiff.toStringAsFixed(1)}°C lebih hangat'
            : '${tempDiff.abs().toStringAsFixed(1)}°C lebih sejuk');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Insight Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E293B)
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Text(
            _getInsightTip(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // Section header
        Row(
          children: [
            Icon(
              Icons.dashboard_rounded,
              size: 19,
              color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              'Parameter Cuaca Lengkap',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 3-column grid
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.thermostat_rounded,
                label: 'Terasa Seperti',
                value: '${apparentTemperature.toStringAsFixed(1)}°C',
                sub: tempDiffStr,
                accentColor: const Color(0xFFD97706), // muted amber
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.water_drop_rounded,
                label: 'Kelembapan',
                value: '$relativeHumidity%',
                sub: relativeHumidity < 40 ? 'Kering' : (relativeHumidity <= 70 ? 'Nyaman' : 'Lembap Tinggi'),
                accentColor: const Color(0xFF0284C7), // muted sky blue
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.air_rounded,
                label: 'Kecepatan Angin',
                value: '${windSpeed.toStringAsFixed(1)} km/j',
                sub: windSpeed < 5 ? 'Tenang' : (windSpeed < 20 ? 'Sepoi-sepoi' : 'Sedang'),
                accentColor: const Color(0xFF0D9488), // muted teal
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.grain_rounded,
                label: 'Curah Hujan',
                value: '${precipitation.toStringAsFixed(1)} mm',
                sub: 'Peluang $precipitationProbability%',
                accentColor: const Color(0xFF6366F1), // muted indigo
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.arrow_upward_rounded,
                label: 'Suhu Maksimum',
                value: '${maxTemperature.toStringAsFixed(1)}°C',
                sub: 'Puncak siang hari',
                accentColor: const Color(0xFFE11D48), // muted rose
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MetricTile(
                icon: Icons.arrow_downward_rounded,
                label: 'Suhu Minimum',
                value: '${minTemperature.toStringAsFixed(1)}°C',
                sub: 'Suhu terendah malam',
                accentColor: const Color(0xFF0891B2), // muted cyan
                isDark: isDark,
              ),
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
  final bool isDark;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9,
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
