import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_widget.dart';
import '../widgets/hourly_forecast_widget.dart';
import '../widgets/weather_header_card.dart';
import '../widgets/weather_info_card.dart';
import 'search_screen.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().init();
    });
  }

  void _openSearchScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SearchScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.cloud, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Aire Weather',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: 'Cari Kota',
            onPressed: _openSearchScreen,
          ),
          Consumer<WeatherViewModel>(
            builder: (context, vm, _) {
              return IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Segarkan',
                onPressed: vm.isLoadingWeather ? null : () => vm.fetchWeather(),
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, _) {
          if (vm.weatherState == ViewState.loading && vm.weatherData == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 72,
                      height: 72,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.cloud, size: 72, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data cuaca Open-Meteo...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (vm.weatherState == ViewState.error && vm.weatherData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.cloud_off_rounded,
                        size: 64,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Gagal Memuat Cuaca',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.weatherError,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => vm.fetchWeather(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final weather = vm.weatherData;
          final location = vm.currentLocation;

          if (weather == null || location == null) {
            return const SizedBox.shrink();
          }

          final todayDaily = weather.dailyForecast.isNotEmpty ? weather.dailyForecast.first : null;
          final isFav = vm.isFavorite(location);

          return RefreshIndicator(
            onRefresh: () => vm.fetchWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favorite chips row (quick switcher)
                  if (vm.favorites.where((f) => f.name.trim().isNotEmpty).isNotEmpty) ...[
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.favorites.where((f) => f.name.trim().isNotEmpty).length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final fav = vm.favorites.where((f) => f.name.trim().isNotEmpty).toList()[index];
                          final isSelected = fav.name.toLowerCase() == location.name.toLowerCase();
                          return ChoiceChip(
                            showCheckmark: false,
                            avatar: Icon(
                              Icons.favorite_rounded,
                              size: 14,
                              color: isSelected
                                  ? (isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1))
                                  : (isDark ? Colors.grey[400] : Colors.grey[500]),
                            ),
                            label: Text(
                              fav.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                fontSize: 13,
                                color: isSelected
                                    ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                    : (isDark ? Colors.grey[300] : Colors.grey[700]),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: isDark
                                ? const Color(0xFF1E3A5F)
                                : const Color(0xFFE0F2FE),
                            backgroundColor: isDark
                                ? const Color(0xFF1E293B)
                                : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF7DD3FC))
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: 1,
                            ),
                            onSelected: (selected) {
                              if (selected && !isSelected) {
                                vm.selectLocation(fav, saveToHistory: false);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Hero Header Card
                  WeatherHeaderCard(
                    location: location,
                    current: weather.current,
                    todayDaily: todayDaily,
                    isFavorite: isFav,
                    onToggleFavorite: () {
                      final willBeFavorite = !isFav;
                      vm.toggleFavorite(location);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            willBeFavorite
                                ? '${location.name} ditambahkan ke favorit ❤️'
                                : '${location.name} dihapus dari favorit',
                          ),
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    onSearchTap: _openSearchScreen,
                  ),

                  const SizedBox(height: 16),

                  // Prakiraan per jam
                  HourlyForecastWidget(
                    hourlyForecast: weather.hourlyForecast,
                  ),

                  const SizedBox(height: 16),

                  // Prakiraan 7 hari
                  DailyForecastWidget(
                    dailyForecast: weather.dailyForecast,
                  ),

                  const SizedBox(height: 16),

                  // Detail parameter cuaca
                  WeatherInfoGrid(
                    currentTemperature: weather.current.temperature,
                    apparentTemperature: weather.current.apparentTemperature,
                    relativeHumidity: weather.current.relativeHumidity,
                    windSpeed: weather.current.windSpeed,
                    precipitation: weather.current.precipitation,
                    precipitationProbability: todayDaily?.maxPrecipitationProbability ?? 0,
                    maxTemperature: todayDaily?.maxTemperature ?? weather.current.temperature,
                    minTemperature: todayDaily?.minTemperature ?? weather.current.temperature,
                    weatherCode: weather.current.weatherCode,
                  ),

                  const SizedBox(height: 24),

                  Center(
                    child: Text(
                      'Sumber data: Open-Meteo API',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
