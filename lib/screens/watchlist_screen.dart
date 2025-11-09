import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widget/watchlist_item.dart';
import '../models/user_movie.dart';
import '../models/movie.dart';
import '../services/firebase_service.dart';
import 'browse_movies_screen.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({Key? key}) : super(key: key);

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _selectedFilter = 'all';
  String _sortBy = 'addedAt'; // addedAt, title, rating, releaseDate, userScore

  final List<Map<String, String>> filters = [
    {'key': 'all', 'label': 'All'},
    {'key': 'favourite', 'label': 'Favourites'},
    {'key': 'planning', 'label': 'Planning'},
    {'key': 'watching', 'label': 'Watching'},
    {'key': 'completed', 'label': 'Completed'},
    {'key': 'dropped', 'label': 'Dropped'},
  ];

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
                final filter = filters[index];
                final isSelected = _selectedFilter == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['key']!;
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
         // Update the stats calculation in the StreamBuilder:
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _firebaseService.getUserMoviesByStatus('all'),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 80);
              }

              final allMovies = snapshot.data!;
              
              // FIXED: Count completed movies (which includes favourites)
              final watched = allMovies.where((m) => 
                m['status'] == 'completed'
              ).length;
              
              final planning = allMovies.where((m) => 
                m['status'] == 'planning'
              ).length;
              
              final dropped = allMovies.where((m) => 
                m['status'] == 'dropped'
              ).length;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _buildStatCard('${allMovies.length}', 'Total'),
                    const SizedBox(width: 12),
                    _buildStatCard('$watched', 'Watched'),
                    const SizedBox(width: 12),
                    _buildStatCard('$planning', 'Planning'),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Watchlist Items
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _firebaseService.getUserMoviesByStatus(_selectedFilter),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6366F1),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  // Print the full error to console with clickable link
                  print('═══════════════════════════════════════════════════════');
                  print('🔥 FIRESTORE ERROR - INDEX REQUIRED 🔥');
                  print('═══════════════════════════════════════════════════════');
                  print(snapshot.error.toString());
                  print('═══════════════════════════════════════════════════════');
                  print('👆 CLICK THE LINK ABOVE TO CREATE THE INDEX 👆');
                  print('═══════════════════════════════════════════════════════');
                  
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading watchlist',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Index required. Check terminal for clickable link to create it.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Print again in case user missed it
                            print('\n🔥 FIRESTORE INDEX LINK 🔥');
                            print(snapshot.error.toString());
                            print('👆 CLICK THE LINK ABOVE 👆\n');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Print Link Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                List<UserMovie> movies = snapshot.data!
                    .map((data) => UserMovie.fromFirestore(data, data['id']))
                    .toList();

                if (_selectedFilter == 'completed') {
                  // Show all completed movies (including favourites)
                  // Since favourites are stored as status='completed' with isFavourite=true,
                  // this will automatically include them
                  movies = movies.where((m) => m.status == 'completed').toList();
                } else if (_selectedFilter == 'favourite') {
                  // Show only favourites (completed movies with isFavourite=true)
                  movies = movies.where((m) => 
                    m.status == 'completed' && m.isFavourite == true
                  ).toList();
                } else if (_selectedFilter != 'all') {
                  // For other filters (planning, watching, dropped), keep only exact status matches
                  movies = movies.where((m) => m.status == _selectedFilter).toList();
                }

                // Sort movies
                movies = _sortMovies(movies);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    return WatchlistItem(
                      userMovie: movies[index],
                      onRemove: () => _removeMovie(movies[index]),
                      onUpdateStatus: (status) => _updateStatus(movies[index], status),
                      onUpdateScore: (score) => _updateScore(movies[index], score),
                      onTap: () => _navigateToMovieDetail(movies[index]),
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
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all' 
                ? 'Your watchlist is empty'
                : 'No ${_getFilterLabel()} movies',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding movies and shows!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to browse/explore screen
              Navigator.pushNamed(
                context,
                '/browse',
                arguments: {
                  'category': BrowseCategory.trending,
                  'genreFilter': null,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.explore_rounded, color: Colors.white),
            label: const Text('Explore Movies', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getFilterLabel() {
    return filters.firstWhere(
      (f) => f['key'] == _selectedFilter,
      orElse: () => {'label': ''},
    )['label']!.toLowerCase();
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
            _buildSortOption('Recently Added', 'addedAt'),
            _buildSortOption('Title (A-Z)', 'title'),
            _buildSortOption('TMDB Rating', 'rating'),
            _buildSortOption('Release Year', 'releaseDate'),
            _buildSortOption('My Rating', 'userScore'),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildSortOption(String label, String sortKey) {
    final isSelected = _sortBy == sortKey;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.check_circle_rounded : Icons.sort_rounded,
        color: const Color(0xFF6366F1),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _sortBy = sortKey;
        });
        Navigator.pop(context);
      },
    );
  }

  List<UserMovie> _sortMovies(List<UserMovie> movies) {
    switch (_sortBy) {
      case 'title':
        movies.sort((a, b) => a.movieTitle.compareTo(b.movieTitle));
        break;
      case 'rating':
        movies.sort((a, b) => b.movieRating.compareTo(a.movieRating));
        break;
      case 'releaseDate':
        movies.sort((a, b) => b.movieYear.compareTo(a.movieYear));
        break;
      case 'userScore':
        movies.sort((a, b) {
          if (a.userScore == null && b.userScore == null) return 0;
          if (a.userScore == null) return 1;
          if (b.userScore == null) return -1;
          return b.userScore!.compareTo(a.userScore!);
        });
        break;
      case 'addedAt':
      default:
        movies.sort((a, b) => b.addedAt.compareTo(a.addedAt));
        break;
    }
    return movies;
  }

  Future<void> _removeMovie(UserMovie movie) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Remove Movie',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Remove "${movie.movieTitle}" from your watchlist?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.removeMovieFromList(movie.movieId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${movie.movieTitle} removed from watchlist'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Update _updateStatus to handle the removal of 'favourite' status:
  Future<void> _updateStatus(UserMovie movie, String newStatus) async {
    try {
      await _firebaseService.addMovieToList(
        movieId: movie.movieId,
        movieTitle: movie.movieTitle,
        moviePosterPath: movie.moviePosterPath,
        movieBackdropPath: movie.movieBackdropPath,
        movieGenre: movie.movieGenre,
        movieYear: movie.movieYear,
        movieRating: movie.movieRating,
        status: newStatus, // planning, watching, completed, or dropped
        userScore: movie.userScore,
        isFavourite: movie.isFavourite, // Preserve favourite status
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${_getStatusLabel(newStatus)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateScore(UserMovie movie, double score) async {
    try {
      await _firebaseService.updateMovieScore(movie.movieId, score);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rating updated to ${score.toStringAsFixed(1)}/10'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return 'Plan to Watch';
      case 'watching':
        return 'Watching';
      case 'completed':
        return 'Completed';
      case 'dropped':
        return 'Dropped';
      default:
        return status;
    }
  }

  void _navigateToMovieDetail(UserMovie userMovie) {
    // Create a Movie object from UserMovie data
    final movie = Movie(
      id: userMovie.movieId.toString(),
      title: userMovie.movieTitle,
      genre: userMovie.movieGenre,
      rating: userMovie.movieRating,
      year: userMovie.movieYear,
      imageColor: _getColorFromPath(userMovie.moviePosterPath),
      posterPath: userMovie.moviePosterPath.isNotEmpty ? userMovie.moviePosterPath : null,
      backdropPath: userMovie.movieBackdropPath?.isNotEmpty == true ? userMovie.movieBackdropPath : null,
      overview: null, // Will be loaded from TMDB in detail screen
      genreIds: _getGenreIds(userMovie.movieGenre),
    );
    
    Navigator.pushNamed(
      context,
      '/movie-detail',
      arguments: movie,
    );
  }

  String _getColorFromPath(String path) {
    if (path.isEmpty) return '6366F1';
    
    final hash = path.hashCode.abs();
    const colors = [
      'FF9800', 'E91E63', '424242', 'FFEB3B', '795548',
      '5D4037', 'D32F2F', '607D8B', '1A237E', 'E0E0E0',
      'C62828', '546E7A', 'FF6F00', '37474F', '212121',
      '4CAF50', '1B5E20', '6D4C41', '6366F1', 'A78BFA',
    ];
    return colors[hash % colors.length];
  }

  List<int>? _getGenreIds(String genreName) {
    const genreMap = {
      'Action': [28],
      'Adventure': [12],
      'Animation': [16],
      'Comedy': [35],
      'Crime': [80],
      'Documentary': [99],
      'Drama': [18],
      'Family': [10751],
      'Fantasy': [14],
      'History': [36],
      'Horror': [27],
      'Music': [10402],
      'Mystery': [9648],
      'Romance': [10749],
      'Sci-Fi': [878],
      'TV Movie': [10770],
      'Thriller': [53],
      'War': [10752],
      'Western': [37],
    };
    
    return genreMap[genreName];
  }
}