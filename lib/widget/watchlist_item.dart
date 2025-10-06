import 'package:flutter/material.dart';
import '../models/movie.dart';

class WatchlistItem extends StatelessWidget {
  final Movie movie;

  const WatchlistItem({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Movie Poster
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: Color(int.parse('FF${movie.imageColor}', radix: 16)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(
                              int.parse('FF${movie.imageColor}', radix: 16),
                            ),
                            Color(
                              int.parse('FF${movie.imageColor}', radix: 16),
                            ).withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.movie_rounded,
                        size: 32,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Movie Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${movie.year} • ${movie.genre}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
                              movie.rating.toString(),
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
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

            // Actions
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.check_circle_rounded),
                  color: const Color(0xFF6366F1),
                  onPressed: () {},
                  tooltip: 'Mark as watched',
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  color: Colors.red.withOpacity(0.8),
                  onPressed: () {},
                  tooltip: 'Remove',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
