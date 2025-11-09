import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../widget/movie_card.dart';

enum BrowseCategory { trending, topRated, recommended, nowPlaying, upcoming }

class BrowseMoviesScreen extends StatefulWidget {
  final BrowseCategory category;
  final String? genreFilter;

  const BrowseMoviesScreen({Key? key, required this.category, this.genreFilter})
    : super(key: key);

  @override
  State<BrowseMoviesScreen> createState() => _BrowseMoviesScreenState();
}

class _BrowseMoviesScreenState extends State<BrowseMoviesScreen> {
  final TMDBService _tmdbService = TMDBService();
  final ScrollController _scrollController = ScrollController();

  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMore) {
        _loadMoreMovies();
      }
    }
  }

  String _getCategoryTitle() {
    switch (widget.category) {
      case BrowseCategory.trending:
        return 'Trending Now';
      case BrowseCategory.topRated:
        return 'Top Rated';
      case BrowseCategory.recommended:
        return 'Recommended For You';
      case BrowseCategory.nowPlaying:
        return 'Now Playing';
      case BrowseCategory.upcoming:
        return 'Coming Soon';
    }
  }

  String _getCategorySubtitle() {
    if (widget.genreFilter != null && widget.genreFilter != 'All') {
      return '${widget.genreFilter} Movies';
    }
    return '';
  }

  Future<List<Movie>> _fetchMoviesByCategory(int page) async {
    final genreId = widget.genreFilter != null && widget.genreFilter != 'All'
        ? TMDBService.getGenreId(widget.genreFilter!)
        : null;

    // If genre filter is applied, fetch by genre
    if (genreId != null) {
      return await _tmdbService.getMoviesByGenre(genreId, page: page);
    }

    // Otherwise fetch by category
    switch (widget.category) {
      case BrowseCategory.trending:
        return await _tmdbService.getTrendingMovies(
          timeWindow: 'week',
          page: page,
        );
      case BrowseCategory.topRated:
        return await _tmdbService.getTopRatedMovies(page: page);
      case BrowseCategory.recommended:
        return await _tmdbService.getUpcomingMovies(page: page);
      case BrowseCategory.nowPlaying:
        return await _tmdbService.getNowPlayingMovies(page: page);
      case BrowseCategory.upcoming:
        return await _tmdbService.getUpcomingMovies(page: page);
    }
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final movies = await _fetchMoviesByCategory(1);
      if (mounted) {
        setState(() {
          _movies = movies;
          _isLoading = false;
          _currentPage = 1;
          _hasMore = movies.length >= 20; // TMDB typically returns 20 per page
        });
      }
    } catch (e) {
      print('Error loading movies: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final movies = await _fetchMoviesByCategory(nextPage);

      if (mounted) {
        setState(() {
          if (movies.isEmpty) {
            _hasMore = false;
          } else {
            _movies.addAll(movies);
            _currentPage = nextPage;
            _hasMore = movies.length >= 20;
          }
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error loading more movies: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getCategoryTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_getCategorySubtitle().isNotEmpty)
                  Text(
                    _getCategorySubtitle(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),

          // Loading State
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF6366F1)),
              ),
            )
          else ...[
            // Movie Count Header
            if (_movies.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Text(
                    '${_movies.length}+ Movies',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Movie Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 20,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index < _movies.length) {
                    return MovieCard(
                      movie: _movies[index],
                      showRating: widget.category == BrowseCategory.topRated,
                    );
                  }
                  return null;
                }, childCount: _movies.length),
              ),
            ),

            // Loading More Indicator
            if (_isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)),
                  ),
                ),
              ),

            // End of Results
            if (!_hasMore && _movies.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 32,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ve reached the end',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Empty State
            if (!_isLoading && _movies.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No movies found',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Bottom Padding for safe area
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
