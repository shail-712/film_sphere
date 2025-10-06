import 'package:flutter/material.dart';
import '../widget/movie_card.dart';
import '../widget/category_chip.dart';
import '../models/movie.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Action',
    'Drama',
    'Comedy',
    'Sci-Fi',
    'Horror',
    'Romance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: const Color(0xFF0F0F0F),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'FilmSphere',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search movies, shows, people...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    suffixIcon: Icon(
                      Icons.mic_rounded,
                      color: Colors.white.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: categories[index],
                    isSelected: _selectedCategory == categories[index],
                    onTap: () {
                      setState(() {
                        _selectedCategory = categories[index];
                      });
                    },
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Trending Now
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Trending Now',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: Movie.trendingMovies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: Movie.trendingMovies[index],
                    width: 160,
                    height: 240,
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Top Rated
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Rated',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: Movie.topRatedMovies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: Movie.topRatedMovies[index],
                    width: 140,
                    height: 180,
                    showRating: true,
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Recommended
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recommended For You',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 260,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: Movie.recommendedMovies.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    movie: Movie.recommendedMovies[index],
                    width: 140,
                    height: 180,
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
