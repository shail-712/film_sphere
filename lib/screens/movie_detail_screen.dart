import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_constants.dart';
import '../services/tmdb_service.dart';
import '../services/firebase_movie_service.dart';
import '../widget/movie_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final TMDBService _tmdbService = TMDBService();
  final FirebaseMovieService _movieService = FirebaseMovieService();

  Map<String, dynamic>? _movieDetails;
  Map<String, dynamic>? _credits;
  List<Movie> _similarMovies = [];
  Map<String, dynamic>? _userMovieStatus;
  List<Map<String, dynamic>> _friendsActivity = [];
  Map<String, int> _statusCounts = {};

  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isInList = false;
  String _currentStatus = '';
  double? _userScore;

  @override
  void initState() {
    super.initState();
    _loadMovieData();
  }

  Future<void> _loadMovieData() async {
    setState(() => _isLoading = true);

    try {
      // Load TMDB data
      final details = await _tmdbService.getMovieDetails(widget.movie.id);
      final credits = await _tmdbService.getMovieCredits(widget.movie.id);
      final similar = await _tmdbService.getSimilarMovies(widget.movie.id);

      // Load Firebase data
      final userStatus = await _movieService.getUserMovieStatus(
        widget.movie.id,
      );
      final friendsActivity = await _movieService.getFriendsActivity(
        widget.movie.id,
      );
      final statusCounts = await _movieService.getFriendsStatusCounts(
        widget.movie.id,
      );

      if (mounted) {
        setState(() {
          _movieDetails = details;
          _credits = credits;
          _similarMovies = similar;
          _userMovieStatus = userStatus;
          _friendsActivity = friendsActivity;
          _statusCounts = statusCounts;

          // Update user status
          if (userStatus != null) {
            _isInList = true;
            _isFavorite = userStatus['isFavourite'] == true;
            _currentStatus = userStatus['status'] ?? '';
            _userScore = (userStatus['userScore'] as num?)?.toDouble();
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading movie data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addToList(String status) async {
    try {
      await _movieService.addMovieToList(
        movie: widget.movie,
        status: status,
        userScore: _userScore,
      );

      if (mounted) {
        setState(() {
          _isInList = true;
          _currentStatus = status;
          if (status == 'favourite') {
            _isFavorite = true;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added to ${_formatStatus(status)}'),
            backgroundColor: const Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Reload data
      _loadMovieData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final newFavoriteState = !_isFavorite;
      await _movieService.toggleFavorite(widget.movie, newFavoriteState);

      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteState;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteState
                  ? 'Added to favorites'
                  : 'Removed from favorites',
            ),
            backgroundColor: const Color(0xFF6366F1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Reload data
      _loadMovieData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showScoreDialog() async {
    double tempScore = _userScore ?? 5.0;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Rate this movie',
          style: TextStyle(color: Colors.white),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempScore.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: tempScore,
                min: 0,
                max: 10,
                divisions: 20,
                activeColor: const Color(0xFF6366F1),
                onChanged: (value) {
                  setDialogState(() {
                    tempScore = value;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  Text(
                    '10',
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                if (_isInList) {
                  await _movieService.updateMovieScore(
                    widget.movie.id,
                    tempScore,
                  );
                } else {
                  await _addToList('completed');
                  await _movieService.updateMovieScore(
                    widget.movie.id,
                    tempScore,
                  );
                }

                setState(() {
                  _userScore = tempScore;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Score updated'),
                    backgroundColor: Color(0xFF6366F1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    return status.substring(0, 1).toUpperCase() + status.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Backdrop
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _isFavorite ? Colors.red : Colors.white,
                  ),
                ),
                onPressed: _toggleFavorite,
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop Image
                  if (widget.movie.backdropPath != null)
                    Image.network(
                      ApiConstants.getBackdropUrl(
                        widget.movie.backdropPath,
                        isLarge: true,
                      ),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Color(
                            int.parse('0xFF${widget.movie.imageColor}'),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Color(int.parse('0xFF${widget.movie.imageColor}')),
                    ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          const Color(0xFF0F0F0F),
                        ],
                      ),
                    ),
                  ),

                  // Movie Title and Basic Info
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.movie.genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.movie.year}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            if (_userScore != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Your score: ',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _userScore!.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PopupMenuButton<String>(
                      onSelected: (value) => _addToList(value),
                      color: const Color(0xFF1A1A1A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => [
                        _buildPopupMenuItem(
                          'planning',
                          Icons.schedule_rounded,
                          Colors.blue,
                        ),
                        _buildPopupMenuItem(
                          'watching',
                          Icons.play_circle_rounded,
                          Colors.orange,
                        ),
                        _buildPopupMenuItem(
                          'completed',
                          Icons.check_circle_rounded,
                          Colors.green,
                        ),
                        _buildPopupMenuItem(
                          'dropped',
                          Icons.cancel_rounded,
                          Colors.red,
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _isInList
                              ? Colors.green
                              : const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isInList
                                  ? Icons.check_rounded
                                  : Icons.add_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isInList
                                  ? _formatStatus(_currentStatus)
                                  : 'Add to List',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _showScoreDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 24,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _userScore != null
                                  ? _userScore!.toStringAsFixed(1)
                                  : 'Rate',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Overview Section
          if (widget.movie.overview != null &&
              widget.movie.overview!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.movie.overview!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Friends Activity Section
          if (_friendsActivity.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.people_rounded,
                          color: Color(0xFF6366F1),
                          size: 22,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Friends Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFriendsStatusSection(),
                  ],
                ),
              ),
            ),

          if (_friendsActivity.isNotEmpty)
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Cast Section
          if (_credits != null && _credits!['cast'] != null)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Cast',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: (_credits!['cast'] as List).length > 10
                          ? 10
                          : (_credits!['cast'] as List).length,
                      itemBuilder: (context, index) {
                        final cast = (_credits!['cast'] as List)[index];
                        return _buildCastCard(cast);
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),

          // Similar Movies Section
          if (_similarMovies.isNotEmpty)
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Similar Movies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _similarMovies.length > 10
                          ? 10
                          : _similarMovies.length,
                      itemBuilder: (context, index) {
                        return MovieCard(
                          movie: _similarMovies[index],
                          width: 140,
                          height: 200,
                          showRating: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    IconData icon,
    Color color,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            _formatStatus(value),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsStatusSection() {
    return Column(
      children: [
        // Status Summary Cards
        Row(
          children: [
            _buildStatusCard(
              'Planning',
              _statusCounts['planning'] ?? 0,
              Icons.schedule_rounded,
              Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildStatusCard(
              'Watching',
              _statusCounts['watching'] ?? 0,
              Icons.play_circle_rounded,
              Colors.orange,
            ),
            const SizedBox(width: 12),
            _buildStatusCard(
              'Completed',
              _statusCounts['completed'] ?? 0,
              Icons.check_circle_rounded,
              Colors.green,
            ),
            const SizedBox(width: 12),
            _buildStatusCard(
              'Dropped',
              _statusCounts['dropped'] ?? 0,
              Icons.cancel_rounded,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Friends List with Status
        ..._friendsActivity.take(5).map((activity) {
          final userData = activity['user'] as Map<String, dynamic>;
          final status = activity['status'] as String;
          final userScore = (activity['userScore'] as num?)?.toDouble();
          final updatedAt = (activity['updatedAt'] as dynamic);

          return _buildFriendActivityCard(
            userData,
            status,
            userScore,
            updatedAt,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildStatusCard(String label, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendActivityCard(
    Map<String, dynamic> userData,
    String status,
    double? userScore,
    dynamic updatedAt,
  ) {
    final username =
        userData['username'] ?? userData['displayName'] ?? 'Unknown';
    final timeAgo = _getTimeAgo(updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF6366F1),
            backgroundImage: userData['profileImageUrl'] != null
                ? NetworkImage(userData['profileImageUrl'])
                : null,
            child: userData['profileImageUrl'] == null
                ? Text(
                    username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(status),
                            size: 12,
                            color: _getStatusColor(status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatStatus(status),
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (userScore != null) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        userScore.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            timeAgo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCastCard(Map<String, dynamic> cast) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1A1A1A),
              image: cast['profile_path'] != null
                  ? DecorationImage(
                      image: NetworkImage(
                        ApiConstants.getImageUrl(
                          cast['profile_path'],
                          size: ApiConstants.posterSizeSmall,
                        ),
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: cast['profile_path'] == null
                ? Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white.withOpacity(0.3),
                      size: 40,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          Text(
            cast['name'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Icons.schedule_rounded;
      case 'watching':
        return Icons.play_circle_rounded;
      case 'completed':
      case 'favourite':
        return Icons.check_circle_rounded;
      case 'dropped':
        return Icons.cancel_rounded;
      default:
        return Icons.bookmark_rounded;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'planning':
        return Colors.blue;
      case 'watching':
        return Colors.orange;
      case 'completed':
      case 'favourite':
        return Colors.green;
      case 'dropped':
        return Colors.red;
      default:
        return const Color(0xFF6366F1);
    }
  }

  String _getTimeAgo(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime;
      if (timestamp is Timestamp) {
        dateTime = timestamp.toDate();
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        return '';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '${months}mo ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '';
    }
  }
}
