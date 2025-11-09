import 'package:cloud_firestore/cloud_firestore.dart';

class UserMovie {
  final String id;
  final String userId;
  final int movieId;
  final String movieTitle;
  final String moviePosterPath;
  final String? movieBackdropPath;
  final String movieGenre;
  final int movieYear;
  final double movieRating;
  final String status; // favourite, planning, watching, completed, dropped
  final double? userScore;
  final bool isFavourite;
  final DateTime addedAt;
  final DateTime? completedAt;
  final DateTime updatedAt;
  final String? notes;

  UserMovie({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterPath,
    this.movieBackdropPath,
    required this.movieGenre,
    required this.movieYear,
    required this.movieRating,
    required this.status,
    this.userScore,
    required this.isFavourite,
    required this.addedAt,
    this.completedAt,
    required this.updatedAt,
    this.notes,
  });

  // Factory constructor from Firebase document
  factory UserMovie.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserMovie(
      id: docId,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? 0,
      movieTitle: data['movieTitle'] ?? 'Unknown',
      moviePosterPath: data['moviePosterPath'] ?? '',
      movieBackdropPath: data['movieBackdropPath'],
      movieGenre: data['movieGenre'] ?? 'Unknown',
      movieYear: data['movieYear'] ?? 0,
      movieRating: (data['movieRating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'planning',
      userScore: data['userScore'] != null 
          ? (data['userScore'] as num).toDouble() 
          : null,
      isFavourite: data['isFavourite'] ?? false,
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notes: data['notes'],
    );
  }

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'movieBackdropPath': movieBackdropPath,
      'movieGenre': movieGenre,
      'movieYear': movieYear,
      'movieRating': movieRating,
      'status': status,
      'userScore': userScore,
      'isFavourite': isFavourite,
      'addedAt': Timestamp.fromDate(addedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notes': notes,
    };
  }

  // Get status display name
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'favourite':
        return 'Favourite';
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

  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'favourite':
        return 'FFD700'; // Gold
      case 'planning':
        return '6366F1'; // Indigo
      case 'watching':
        return '10B981'; // Green
      case 'completed':
        return '3B82F6'; // Blue
      case 'dropped':
        return 'EF4444'; // Red
      default:
        return '6366F1';
    }
  }

  // Copy with method for updates
  UserMovie copyWith({
    String? id,
    String? userId,
    int? movieId,
    String? movieTitle,
    String? moviePosterPath,
    String? movieBackdropPath,
    String? movieGenre,
    int? movieYear,
    double? movieRating,
    String? status,
    double? userScore,
    bool? isFavourite,
    DateTime? addedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
    String? notes,
  }) {
    return UserMovie(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterPath: moviePosterPath ?? this.moviePosterPath,
      movieBackdropPath: movieBackdropPath ?? this.movieBackdropPath,
      movieGenre: movieGenre ?? this.movieGenre,
      movieYear: movieYear ?? this.movieYear,
      movieRating: movieRating ?? this.movieRating,
      status: status ?? this.status,
      userScore: userScore ?? this.userScore,
      isFavourite: isFavourite ?? this.isFavourite,
      addedAt: addedAt ?? this.addedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }
}