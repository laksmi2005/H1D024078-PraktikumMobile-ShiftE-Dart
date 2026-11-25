import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/location_model.dart';
import '../../viewmodels/weather_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Clear previous search results on opening
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().clearSearch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        context.read<WeatherViewModel>().searchCities(query);
      }
    });
  }

  void _onSelectLocation(LocationModel location) {
    final vm = context.read<WeatherViewModel>();
    vm.selectLocation(location);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Kota / Lokasi'),
      ),
      body: Column(
        children: [
          // Search TextField Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: (q) {
                  _debounce?.cancel();
                  context.read<WeatherViewModel>().searchCities(q);
                },
                decoration: InputDecoration(
                  hintText: 'Ketik nama kota (misal: Bandung, Tokyo)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            context.read<WeatherViewModel>().clearSearch();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Content body
          Expanded(
            child: Consumer<WeatherViewModel>(
              builder: (context, vm, _) {
                // If query is empty -> show Favorites & History
                if (_searchController.text.trim().isEmpty) {
                  return _buildFavoritesAndHistory(context, vm);
                }

                // If searching
                if (vm.isSearching) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Mencari kota melalui Open-Meteo...'),
                      ],
                    ),
                  );
                }

                // If search error
                if (vm.searchState == ViewState.error) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 54, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Gagal Mencari Lokasi',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            vm.searchError,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => vm.searchCities(_searchController.text),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If search empty
                if (vm.searchState == ViewState.empty || vm.searchResults.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_off_rounded, size: 56, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Kota Tidak Ditemukan',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Coba periksa ejaan nama kota atau cari kota lain.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // If results available
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: vm.searchResults.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = vm.searchResults[index];
                    final isFav = vm.isFavorite(item);

                    return Card(
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.location_city_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          [
                            if (item.admin1 != null && item.admin1!.isNotEmpty && item.admin1 != item.name)
                              item.admin1,
                            if (item.country != null) item.country,
                            '(${item.latitude.toStringAsFixed(2)}, ${item.longitude.toStringAsFixed(2)})',
                          ].join(', '),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? Colors.redAccent : Colors.grey,
                          ),
                          tooltip: isFav ? 'Hapus Favorit' : 'Simpan Favorit',
                          onPressed: () {
                            final willBeFav = !isFav;
                            vm.toggleFavorite(item);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  willBeFav
                                      ? '${item.name} ditambahkan ke favorit ❤️'
                                      : '${item.name} dihapus dari favorit',
                                ),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        onTap: () => _onSelectLocation(item),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesAndHistory(BuildContext context, WeatherViewModel vm) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final favorites = vm.favorites;
    final history = vm.searchHistory;

    if (favorites.isEmpty && history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Mulai Mencari Kota',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Ketik nama kota di atas untuk melihat ramalan cuaca Open-Meteo secara akurat.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Section: Favorit
        if (favorites.isNotEmpty) ...[
          Row(
            children: [
              const Icon(Icons.favorite, size: 20, color: Colors.redAccent),
              const SizedBox(width: 8),
              Text(
                'Lokasi Favorit (${favorites.length})',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...favorites.map(
            (fav) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.favorite, color: Colors.redAccent),
                title: Text(
                  fav.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  fav.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Hapus dari Favorit',
                  onPressed: () => vm.toggleFavorite(fav),
                ),
                onTap: () => _onSelectLocation(fav),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Section: Riwayat Pencarian
        if (history.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.history_rounded, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Riwayat Pencarian',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  vm.clearHistory();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat pencarian telah dibersihkan'),
                      duration: Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ...history.map(
            (item) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  item.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: 'Hapus dari Riwayat',
                  onPressed: () => vm.removeFromHistory(item),
                ),
                onTap: () => _onSelectLocation(item),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
