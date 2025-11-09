import 'package:flutter/material.dart';
import '../widget/movie_card.dart';
import '../widget/category_chip.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'browse_movies_screen.dart' show BrowseMoviesScreen, BrowseCategory;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TMDBService _tmdbService = TMDBService();

  String _selectedCategory = 'All';
  List<Movie> _trendingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _recommendedMovies = [];
  List<Movie> _searchResults = [];

  bool _isLoadingTrending = true;
  bool _isLoadingTopRated = true;
  bool _isLoadingRecommended = true;
  bool _isSearching = false;

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
  void initState() {
    super.initState();
    _loadMovies();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
    } else {
      _performSearch(query);
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      final results = await _tmdbService.searchMovies(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      print('Search error: $e');
    }
  }

  Future<void> _loadMovies() async {
    _loadTrendingMovies();
    _loadTopRatedMovies();
    _loadRecommendedMovies();
  }

  Future<void> _loadTrendingMovies() async {
    try {
      final movies = await _tmdbService.getTrendingMovies(timeWindow: 'week');
      if (mounted) {
        setState(() {
          _trendingMovies = movies;
          _isLoadingTrending = false;
        });
      }
    } catch (e) {
      print('Error loading trending movies: $e');
      if (mounted) {
        setState(() {
          _trendingMovies = Movie.trendingMovies;
          _isLoadingTrending = false;
        });
      }
    }
  }

  Future<void> _loadTopRatedMovies() async {
    try {
      final movies = await _tmdbService.getTopRatedMovies();
      if (mounted) {
        setState(() {
          _topRatedMovies = movies;
          _isLoadingTopRated = false;
        });
      }
    } catch (e) {
      print('Error loading top rated movies: $e');
      if (mounted) {
        setState(() {
          _topRatedMovies = Movie.topRatedMovies;
          _isLoadingTopRated = false;
        });
      }
    }
  }

  Future<void> _loadRecommendedMovies() async {
    try {
      final movies = await _tmdbService.getUpcomingMovies();
      if (mounted) {
        setState(() {
          _recommendedMovies = movies;
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      print('Error loading recommended movies: $e');
      if (mounted) {
        setState(() {
          _recommendedMovies = Movie.recommendedMovies;
          _isLoadingRecommended = false;
        });
      }
    }
  }

  Future<void> _loadMoviesByCategory(String category) async {
    if (category == 'All') {
      _loadMovies();
      return;
    }

    final genreId = TMDBService.getGenreId(category);
    if (genreId == null) return;

    setState(() {
      _isLoadingTrending = true;
      _isLoadingTopRated = true;
      _isLoadingRecommended = true;
    });

    try {
      final movies = await _tmdbService.getMoviesByGenre(genreId);
      if (mounted) {
        setState(() {
          _trendingMovies = movies.take(10).toList();
          _topRatedMovies = movies.skip(10).take(10).toList();
          _recommendedMovies = movies.skip(20).take(10).toList();
          _isLoadingTrending = false;
          _isLoadingTopRated = false;
          _isLoadingRecommended = false;
        });
      }
    } catch (e) {
      print('Error loading movies by category: $e');
      if (mounted) {
        setState(() {
          _isLoadingTrending = false;
          _isLoadingTopRated = false;
          _isLoadingRecommended = false;
        });
      }
    }
  }

  void _navigateToBrowse(BrowseCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowseMoviesScreen(
          category: category,
          genreFilter: _selectedCategory,
        ),
      ),
    );
  }

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
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: Colors.white.withOpacity(0.4),
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : Icon(
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

          // Show search results if searching
          if (_isSearching && _searchResults.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Text(
                  'Search Results (${_searchResults.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return MovieCard(
                    movie: _searchResults[index],
                    showRating: true,
                  );
                }, childCount: _searchResults.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ] else if (_isSearching && _searchResults.isEmpty) ...[
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 64,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No results found',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching for something else',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
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
                        _loadMoviesByCategory(categories[index]);
                      },
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Trending Now Section
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
                    TextButton(
                      onPressed: () =>
                          _navigateToBrowse(BrowseCategory.trending),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 300,
                child: _isLoadingTrending
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _trendingMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _trendingMovies[index],
                            width: 160,
                            height: 240,
                          );
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Top Rated Section
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
                    TextButton(
                      onPressed: () =>
                          _navigateToBrowse(BrowseCategory.topRated),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: _isLoadingTopRated
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _topRatedMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _topRatedMovies[index],
                            width: 140,
                            height: 180,
                            showRating: true,
                          );
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Recommended Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF6366F1),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Recommended For You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () =>
                          _navigateToBrowse(BrowseCategory.recommended),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
                child: _isLoadingRecommended
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _recommendedMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _recommendedMovies[index],
                            width: 140,
                            height: 180,
                          );
                        },
                      ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
