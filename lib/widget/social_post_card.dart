import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import '../services/api_constants.dart';
import '../screens/movie_detail_screen.dart';

class SocialPostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;

  const SocialPostCard({
    Key? key,
    required this.post,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timestamp = post['createdAt'];
    final timeAgo = timestamp != null
        ? timeago.format((timestamp as dynamic).toDate())
        : 'Just now';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1),
                backgroundImage: post['userProfileImage'] != null &&
                        (post['userProfileImage'] as String).isNotEmpty
                    ? NetworkImage(post['userProfileImage'])
                    : null,
                child: post['userProfileImage'] == null ||
                        (post['userProfileImage'] as String).isEmpty
                    ? Text(
                        (post['username'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                      post['username'] ?? 'Unknown User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white.withOpacity(0.5),
                ),
                onPressed: () => _showPostOptions(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Post Content
          Text(
            post['postText'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          // Shared Movie/Review (if applicable)
          if (post['postType'] == 'movie_share' && post['movieId'] != null) ...[
            const SizedBox(height: 12),
            _buildMovieShare(context),
          ],
          if (post['postType'] == 'review_share' && post['reviewId'] != null) ...[
            const SizedBox(height: 12),
            _buildReviewShare(context),
          ],

          const SizedBox(height: 16),

          // Interaction Stats
          Row(
            children: [
              Text(
                '${post['likesCount'] ?? 0} likes',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${post['dislikesCount'] ?? 0} dislikes',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${post['commentsCount'] ?? 0} comments',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const Divider(height: 24, color: Colors.white12),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.thumb_up_outlined,
                'Like',
                onLike,
              ),
              _buildActionButton(
                Icons.thumb_down_outlined,
                'Dislike',
                onDislike,
              ),
              _buildActionButton(
                Icons.chat_bubble_outline_rounded,
                'Comment',
                onComment,
              ),
              _buildActionButton(
                Icons.share_rounded,
                'Share',
                () => _sharePost(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieShare(BuildContext context) {
    final movieId = post['movieId'];
    
    return FutureBuilder<Movie?>(
      future: _fetchMovieDetails(movieId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final movie = snapshot.data;
        if (movie == null) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.movie_rounded, color: Colors.white54),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Movie not found',
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieDetailScreen(movie: movie),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (movie.posterPath?.isNotEmpty ?? false)
                      ? Image.network(
                          ApiConstants.getPosterUrl(movie.posterPath!),
                          width: 60,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 60,
                              height: 90,
                              color: Colors.grey.shade800,
                              child: const Icon(Icons.movie_rounded, color: Colors.white54),
                            );
                          },
                        )
                      : Container(
                          width: 60,
                          height: 90,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.movie_rounded, color: Colors.white54),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            movie.year.toString(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movie.genre,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.white.withOpacity(0.3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Movie?> _fetchMovieDetails(int movieId) async {
  try {
    final tmdbService = TMDBService();
    final movieDetailsMap = await tmdbService.getMovieDetails(movieId.toString());
    
    if (movieDetailsMap == null) {
      return null;
    }
    
    // Convert the Map to a Movie object using Movie.fromJson
    return Movie.fromJson(movieDetailsMap);
  } catch (e) {
    print('Error fetching movie: $e');
    return null;
  }
}

  Widget _buildReviewShare(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.rate_review_rounded,
              color: Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shared Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap to read full review',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_rounded, color: Colors.red),
              title: const Text(
                'Report Post',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reported')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: Colors.white54),
              title: const Text(
                'Block User',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}