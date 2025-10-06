import 'package:flutter/material.dart';
import '../widget/watchlist_item.dart';
import '../models/movie.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  String _selectedFilter = 'All';

  final List<String> filters = ['All', 'Movies', 'TV Shows', 'Want to Watch'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Watchlist',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filters[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filters[index];
                      });
                    },
                    backgroundColor: const Color(0xFF1A1A1A),
                    selectedColor: const Color(0xFF6366F1),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF6366F1)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                );
              },
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _buildStatCard('${Movie.watchlist.length}', 'Total'),
                const SizedBox(width: 12),
                _buildStatCard('12', 'Watched'),
                const SizedBox(width: 12),
                _buildStatCard('8', 'To Watch'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Watchlist Items
          Expanded(
            child: Movie.watchlist.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: Movie.watchlist.length,
                    itemBuilder: (context, index) {
                      return WatchlistItem(movie: Movie.watchlist[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF6366F1),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border_rounded,
            size: 80,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding movies and shows!',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.explore_rounded),
            label: const Text('Explore Movies'),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sort By',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildSortOption('Recently Added'),
            _buildSortOption('Title (A-Z)'),
            _buildSortOption('Rating (High to Low)'),
            _buildSortOption('Release Date'),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String label) {
    return ListTile(
      leading: const Icon(Icons.sort_rounded, color: Color(0xFF6366F1)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
