import 'package:flutter/material.dart';
import '../models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;
  final bool showRating;

  const MovieCard({
    Key? key,
    required this.movie,
    this.width = 140,
    this.height = 200,
    this.showRating = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: _buildPosterStack(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildMovieInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildPosterStack() {
    return Stack(
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Color(int.parse('FF${movie.imageColor}', radix: 16)),
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
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse('FF${movie.imageColor}', radix: 16)),
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
                    size: 48,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bookmark_border_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
        if (showRating)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    movie.rating.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMovieInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movie.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${movie.year} • ${movie.genre}',
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
        ),
      ],
    );
  }
}
