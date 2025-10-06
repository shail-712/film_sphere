import 'package:flutter/material.dart';
import '../models/user.dart';

class FriendCard extends StatelessWidget {
  final User user;
  final bool showFollowButton;

  const FriendCard({
    Key? key,
    required this.user,
    this.showFollowButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF6366F1),
            child: Text(
              user.name.split(' ').map((e) => e[0]).join(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.movie_rounded,
                      size: 14,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${user.moviesWatched} movies',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                    if (user.mutualFriends > 0) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.people_rounded,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.mutualFriends} mutual',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (showFollowButton)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Follow', style: TextStyle(fontSize: 13)),
            )
          else
            IconButton(
              icon: const Icon(Icons.chat_rounded),
              color: const Color(0xFF6366F1),
              onPressed: () {},
            ),
        ],
      ),
    );
  }
}
