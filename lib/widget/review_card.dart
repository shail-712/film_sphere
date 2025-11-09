import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/api_constants.dart';

class ReviewCard extends StatefulWidget {
  final Map<String, dynamic> review;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final VoidCallback onComment;
  final String? userInteraction; // 'like', 'dislike', or null

  const ReviewCard({
    Key? key,
    required this.review,
    required this.onLike,
    required this.onDislike,
    required this.onComment,
    this.userInteraction,
  }) : super(key: key);

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final timestamp = widget.review['createdAt'];
    final timeAgo = timestamp != null
        ? timeago.format((timestamp as dynamic).toDate())
        : 'Just now';

    final reviewScore = widget.review['reviewScore'] ?? 0.0;
    final reviewText = widget.review['reviewText'] ?? '';
    final isLongReview = reviewText.length > 200;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Info Header
          _buildMovieHeader(),

          const Divider(height: 1, color: Colors.white12),

          // Review Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF6366F1),
                      child: Text(
                        (widget.review['userId'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'User Review', // You can fetch username from userId
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
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
                    // Review Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getScoreColor(reviewScore),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reviewScore.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Review Text
                Text(
                  _isExpanded || !isLongReview
                      ? reviewText
                      : '${reviewText.substring(0, 200)}...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),

                // Show More/Less Button
                if (isLongReview) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Interaction Stats
                Row(
                  children: [
                    Text(
                      '${widget.review['likesCount'] ?? 0} likes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.review['dislikesCount'] ?? 0} dislikes',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${widget.review['commentsCount'] ?? 0} comments',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Colors.white12),
                const SizedBox(height: 8),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(
                      Icons.thumb_up_outlined,
                      Icons.thumb_up_rounded,
                      'Like',
                      widget.onLike,
                      widget.userInteraction == 'like',
                    ),
                    _buildActionButton(
                      Icons.thumb_down_outlined,
                      Icons.thumb_down_rounded,
                      'Dislike',
                      widget.onDislike,
                      widget.userInteraction == 'dislike',
                    ),
                    _buildActionButton(
                      Icons.chat_bubble_outline_rounded,
                      Icons.chat_bubble_rounded,
                      'Comment',
                      widget.onComment,
                      false,
                    ),
                    _buildActionButton(
                      Icons.share_rounded,
                      Icons.share_rounded,
                      'Share',
                      () => _shareReview(context),
                      false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieHeader() {
    final movieTitle = widget.review['movieTitle'] ?? 'Unknown Movie';
    final posterPath = widget.review['moviePosterPath'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Movie Poster
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: posterPath.isNotEmpty
                ? Image.network(
                    ApiConstants.getPosterUrl(posterPath),
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderPoster();
                    },
                  )
                : _buildPlaceholderPoster(),
          ),
          const SizedBox(width: 12),

          // Movie Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Review for',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Options Menu
          IconButton(
            icon: Icon(
              Icons.more_vert_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
            onPressed: () => _showReviewOptions(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      width: 50,
      height: 75,
      color: Colors.grey.shade800,
      child: const Icon(
        Icons.movie_rounded,
        color: Colors.white54,
      ),
    );
  }

  Widget _buildActionButton(
    IconData outlinedIcon,
    IconData filledIcon,
    String label,
    VoidCallback onTap,
    bool isActive,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Icon(
              isActive ? filledIcon : outlinedIcon,
              size: 18,
              color: isActive
                  ? const Color(0xFF6366F1)
                  : Colors.white.withOpacity(0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFF6366F1)
                    : Colors.white.withOpacity(0.6),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) {
      return Colors.green.shade600;
    } else if (score >= 6.0) {
      return Colors.orange.shade600;
    } else if (score >= 4.0) {
      return Colors.amber.shade700;
    } else {
      return Colors.red.shade600;
    }
  }

  void _showReviewOptions(BuildContext context) {
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
                'Report Review',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review reported')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded, color: Colors.white54),
              title: const Text(
                'Share Review',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _shareReview(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareReview(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}