import 'package:flutter/material.dart';
import '../models/activity.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;

  const ActivityCard({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // User Info
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF6366F1),
                child: Text(
                  activity.userInitials,
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
                      activity.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      activity.timeAgo,
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
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Action
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              children: [
                TextSpan(text: '${activity.action} '),
                TextSpan(
                  text: activity.movieTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Rating
          if (activity.rating != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < activity.rating!
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  size: 20,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ],

          // Review
          if (activity.review != null) ...[
            const SizedBox(height: 12),
            Text(
              activity.review!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              _buildActionButton(
                Icons.favorite_border_rounded,
                activity.likes.toString(),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                Icons.chat_bubble_outline_rounded,
                activity.comments.toString(),
              ),
              const Spacer(),
              _buildActionButton(Icons.share_rounded, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white.withOpacity(0.6)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
