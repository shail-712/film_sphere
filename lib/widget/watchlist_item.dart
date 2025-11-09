import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user_movie.dart';
import '../services/api_constants.dart';

class WatchlistItem extends StatelessWidget {
  final UserMovie userMovie;
  final VoidCallback onRemove;
  final Function(String) onUpdateStatus;
  final Function(double) onUpdateScore;
  final VoidCallback? onTap; // Add this parameter

  const WatchlistItem({
    Key? key,
    required this.userMovie,
    required this.onRemove,
    required this.onUpdateStatus,
    required this.onUpdateScore,
    this.onTap, // Add this
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap, // Use the callback
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Movie Poster
              _buildPoster(),
              const SizedBox(width: 16),

              // Movie Info
              Expanded(
                child: _buildMovieInfo(),
              ),

              // Actions
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster() {
    return Hero(
      tag: 'movie_${userMovie.movieId}',
      child: Container(
        width: 80,
        height: 120,
        decoration: BoxDecoration(
          color: Color(int.parse('FF${_getColorFromPath()}', radix: 16)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: userMovie.moviePosterPath.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: ApiConstants.getPosterUrl(userMovie.moviePosterPath),
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Color(int.parse('FF${_getColorFromPath()}', radix: 16)),
                    child: Center(
                      child: Icon(
                        Icons.movie_rounded,
                        size: 32,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(int.parse('FF${_getColorFromPath()}', radix: 16)),
                          Color(int.parse('FF${_getColorFromPath()}', radix: 16))
                              .withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.movie_rounded,
                        size: 32,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse('FF${_getColorFromPath()}', radix: 16)),
                        Color(int.parse('FF${_getColorFromPath()}', radix: 16))
                            .withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.movie_rounded,
                      size: 32,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          userMovie.movieTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        // Year & Genre
        Text(
          '${userMovie.movieYear} • ${userMovie.movieGenre}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Color(int.parse('FF${userMovie.statusColor}', radix: 16))
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: Color(int.parse('FF${userMovie.statusColor}', radix: 16))
                  .withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            userMovie.statusDisplayName,
            style: TextStyle(
              color: Color(int.parse('FF${userMovie.statusColor}', radix: 16)),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Ratings Row
        Row(
          children: [
            // TMDB Rating
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFF6366F1),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    userMovie.movieRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // User Score
            if (userMovie.userScore != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${userMovie.userScore!.toStringAsFixed(1)}/10',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Colors.white.withOpacity(0.6),
      ),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (value) {
        switch (value) {
          case 'rate':
            _showRatingDialog(context);
            break;
          case 'status':
            _showStatusDialog(context);
            break;
          case 'remove':
            onRemove();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'rate',
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Text(
                userMovie.userScore != null ? 'Update Rating' : 'Rate Movie',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              const Icon(Icons.edit_rounded, color: Color(0xFF6366F1), size: 20),
              const SizedBox(width: 12),
              const Text(
                'Change Status',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              const Icon(Icons.delete_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context) {
    double currentRating = userMovie.userScore ?? 5.0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Rate this movie',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                userMovie.movieTitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                currentRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'out of 10',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Slider(
                value: currentRating,
                min: 0,
                max: 10,
                divisions: 20,
                activeColor: Colors.amber,
                inactiveColor: Colors.amber.withOpacity(0.3),
                onChanged: (value) {
                  setState(() {
                    currentRating = value;
                  });
                },
              ),
            ],
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
              onPressed: () {
                onUpdateScore(currentRating);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save Rating'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog(BuildContext context) {
    final statuses = [
      {'key': 'planning', 'label': 'Plan to Watch', 'icon': Icons.bookmark_border_rounded},
      {'key': 'watching', 'label': 'Watching', 'icon': Icons.play_circle_outline_rounded},
      {'key': 'completed', 'label': 'Completed', 'icon': Icons.check_circle_outline_rounded},
      {'key': 'favourite', 'label': 'Favourite', 'icon': Icons.favorite_border_rounded},
      {'key': 'dropped', 'label': 'Dropped', 'icon': Icons.close_rounded},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Change Status',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            final isSelected = userMovie.status == status['key'];
            return ListTile(
              leading: Icon(
                status['icon'] as IconData,
                color: isSelected ? const Color(0xFF6366F1) : Colors.white54,
              ),
              title: Text(
                status['label'] as String,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded, color: Color(0xFF6366F1))
                  : null,
              onTap: () {
                onUpdateStatus(status['key'] as String);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getColorFromPath() {
    if (userMovie.moviePosterPath.isEmpty) return '6366F1';
    
    final hash = userMovie.moviePosterPath.hashCode.abs();
    const colors = [
      'FF9800', 'E91E63', '424242', 'FFEB3B', '795548',
      '5D4037', 'D32F2F', '607D8B', '1A237E', 'E0E0E0',
      'C62828', '546E7A', 'FF6F00', '37474F', '212121',
      '4CAF50', '1B5E20', '6D4C41', '6366F1', 'A78BFA',
    ];
    return colors[hash % colors.length];
  }
}