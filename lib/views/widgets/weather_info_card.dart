import 'package:flutter/material.dart';

class WeatherMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color accentColor;
  final Widget? trailingBadge;

  const WeatherMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    required this.accentColor,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.2 : 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon + Label + Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailingBadge,
            ],
          ),

          const SizedBox(height: 10),

          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          // Subtitle / context
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

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

  String _getHumidityStatus(int humidity) {
    if (humidity < 40) return 'Kering';
    if (humidity <= 70) return 'Ideal / Nyaman';
    return 'Lembap Tinggi';
  }

  String _getWindStatus(double speed) {
    if (speed < 5) return 'Tenang';
    if (speed < 20) return 'Sepoi-sepoi';
    if (speed < 40) return 'Sedang';
    return 'Kencang';
  }

  String _getPrecipitationStatus(double prec, int prob) {
    if (prec > 5 || prob >= 80) return 'Potensi Tinggi';
    if (prec > 0.5 || prob >= 40) return 'Gerimis / Sedang';
    return 'Hampir Mustahil';
  }

  String _getInsightTip() {
    if (weatherCode >= 95) {
      return '⚡ Badai petir diprediksi terjadi. Hindari berada di tempat terbuka.';
    } else if (weatherCode >= 51 || precipitationProbability >= 70 || precipitation > 1.0) {
      return '☔ Siapkan payung atau jas hujan, peluang hujan cukup tinggi hari ini.';
    } else if (currentTemperature >= 33) {
      return '☀️ Cuaca cukup terik. Cukupi asupan air minum dan gunakan tabir surya.';
    } else if (windSpeed >= 25) {
      return '💨 Hati-hati dengan hembusan angin kencang saat berkendara.';
    } else {
      return '🌤️ Cuaca bersahabat dan nyaman untuk berbagai aktivitas luar ruangan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tempDiff = apparentTemperature - currentTemperature;
    final tempDiffText = tempDiff.abs() < 0.5
        ? 'Sama dengan suhu riil'
        : (tempDiff > 0
            ? '+${tempDiff.toStringAsFixed(1)}°C lebih hangat'
            : '${tempDiff.toStringAsFixed(1)}°C lebih sejuk');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Smart Weather Insight Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                theme.colorScheme.secondary.withValues(alpha: isDark ? 0.15 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _getInsightTip(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Parameter Cuaca Lengkap',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Open-Meteo',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isDark ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            // 1. Suhu yang dirasakan
            WeatherMetricCard(
              icon: Icons.thermostat_rounded,
              label: 'Terasa Seperti',
              value: '${apparentTemperature.toStringAsFixed(1)}°C',
              subtitle: tempDiffText,
              accentColor: Colors.deepOrangeAccent,
            ),

            // 2. Kelembapan Udara
            WeatherMetricCard(
              icon: Icons.water_drop_rounded,
              label: 'Kelembapan',
              value: '$relativeHumidity%',
              subtitle: _getHumidityStatus(relativeHumidity),
              accentColor: Colors.blueAccent,
            ),

            // 3. Kecepatan Angin
            WeatherMetricCard(
              icon: Icons.air_rounded,
              label: 'Kecepatan Angin',
              value: '${windSpeed.toStringAsFixed(1)} km/j',
              subtitle: _getWindStatus(windSpeed),
              accentColor: Colors.teal,
            ),

            // 4. Curah Hujan & Peluang
            WeatherMetricCard(
              icon: Icons.grain_rounded,
              label: 'Curah Hujan',
              value: '${precipitation.toStringAsFixed(1)} mm',
              subtitle: _getPrecipitationStatus(precipitation, precipitationProbability),
              accentColor: Colors.indigoAccent,
            ),

            // 5. Suhu Maksimum
            WeatherMetricCard(
              icon: Icons.arrow_upward_rounded,
              label: 'Suhu Maksimum',
              value: '${maxTemperature.toStringAsFixed(1)}°C',
              subtitle: 'Puncak suhu siang',
              accentColor: Colors.redAccent,
            ),

            // 6. Suhu Minimum
            WeatherMetricCard(
              icon: Icons.arrow_downward_rounded,
              label: 'Suhu Minimum',
              value: '${minTemperature.toStringAsFixed(1)}°C',
              subtitle: 'Suhu terendah malam',
              accentColor: Colors.cyan,
            ),
          ],
        ),
      ],
    );
  }
}
