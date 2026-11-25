import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../widgets/daily_forecast_widget.dart';
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Favorite chips row (quick switcher)
                  if (vm.favorites.isNotEmpty) ...[
                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: vm.favorites.length,
                        separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final fav = vm.favorites[index];
                          final isSelected = fav.name.toLowerCase() == location.name.toLowerCase();
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                                const SizedBox(width: 4),
                                Text(fav.name),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected && !isSelected) {
                                vm.selectLocation(fav, saveToHistory: false);
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Hero Header Card
                  WeatherHeaderCard(
                    location: location,
                    current: weather.current,
                    todayDaily: todayDaily,
                    isFavorite: isFav,
                    onToggleFavorite: () => vm.toggleFavorite(location),
                    onSearchTap: _openSearchScreen,
                  ),

                  const SizedBox(height: 18),

                  // Detail Metrics Grid
                  WeatherInfoGrid(
                    apparentTemperature: weather.current.apparentTemperature,
                    relativeHumidity: weather.current.relativeHumidity,
                    windSpeed: weather.current.windSpeed,
                    precipitation: weather.current.precipitation,
                    maxTemperature: todayDaily?.maxTemperature ?? weather.current.temperature,
                    minTemperature: todayDaily?.minTemperature ?? weather.current.temperature,
                  ),

                  const SizedBox(height: 18),

                  // 7-day forecast
                  DailyForecastWidget(
                    dailyForecast: weather.dailyForecast,
                  ),

                  const SizedBox(height: 24),

                  // Open-Meteo attribution & App branding
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Data disediakan secara langsung oleh Open-Meteo REST API',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Aire Weather • MVVM Architecture',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                            fontSize: 10,
                          ),
                        ),
                      ],
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
