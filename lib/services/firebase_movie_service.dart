import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class FirebaseMovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Add or update movie in user's list
  Future<void> addMovieToList({
    required Movie movie,
    required String status, // favourite, planning, watching, completed, dropped
    double? userScore,
    String? notes,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}_${movie.id}';
    final isFavourite = status == 'favourite';
    final now = Timestamp.now();

    final data = {
      'userId': currentUserId,
      'movieId': int.parse(movie.id),
      'movieTitle': movie.title,
      'moviePosterPath': movie.posterPath,
      'movieBackdropPath': movie.backdropPath,
      'movieGenre': movie.genre,
      'movieYear': movie.year,
      'movieRating': movie.rating,
      'status': status.toLowerCase(),
      'userScore': userScore,
      'addedAt': now,
      'updatedAt': now,
      'isFavourite': isFavourite,
      'notes': notes,
    };

    // If status is completed or favourite, add completedAt
    if (status.toLowerCase() == 'completed' || isFavourite) {
      data['completedAt'] = now;
    }

    await _firestore
        .collection('user_movies')
        .doc(docId)
        .set(data, SetOptions(merge: true));

    // Update user stats
    await _updateUserStats();
  }

  // Remove movie from user's list
  Future<void> removeMovieFromList(String movieId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}_$movieId';
    await _firestore.collection('user_movies').doc(docId).delete();

    // Update user stats
    await _updateUserStats();
  }

  // Get user's movie status
  Future<Map<String, dynamic>?> getUserMovieStatus(String movieId) async {
    if (currentUserId == null) return null;

    final docId = '${currentUserId}_$movieId';
    final doc = await _firestore.collection('user_movies').doc(docId).get();

    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Update user score for a movie
  Future<void> updateMovieScore(String movieId, double score) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}_$movieId';
    await _firestore.collection('user_movies').doc(docId).update({
      'userScore': score,
      'updatedAt': Timestamp.now(),
    });

    // Update user stats
    await _updateUserStats();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(Movie movie, bool isFavorite) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}_${movie.id}';
    final doc = await _firestore.collection('user_movies').doc(docId).get();

    if (doc.exists) {
      // Update existing entry
      await _firestore.collection('user_movies').doc(docId).update({
        'isFavourite': isFavorite,
        'status': isFavorite
            ? 'favourite'
            : (doc.data()?['status'] ?? 'completed'),
        'completedAt': isFavorite
            ? Timestamp.now()
            : doc.data()?['completedAt'],
        'updatedAt': Timestamp.now(),
      });
    } else if (isFavorite) {
      // Add as favorite
      await addMovieToList(movie: movie, status: 'favourite');
    }

    await _updateUserStats();
  }

  // Get friends' activity for a specific movie
  Future<List<Map<String, dynamic>>> getFriendsActivity(String movieId) async {
    if (currentUserId == null) return [];

    try {
      // Get user's following list
      final followingSnapshot = await _firestore
          .collection('followers')
          .where('followerId', isEqualTo: currentUserId)
          .get();

      final followingIds = followingSnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      // Get friends' movie statuses (Firestore 'in' query limited to 10 items)
      final List<Map<String, dynamic>> friendsActivity = [];

      // Process in batches of 10
      for (var i = 0; i < followingIds.length; i += 10) {
        final batch = followingIds.skip(i).take(10).toList();

        final movieStatusSnapshot = await _firestore
            .collection('user_movies')
            .where('userId', whereIn: batch)
            .where('movieId', isEqualTo: int.parse(movieId))
            .get();

        for (var doc in movieStatusSnapshot.docs) {
          final data = doc.data();

          // Get user info
          final userDoc = await _firestore
              .collection('users')
              .doc(data['userId'])
              .get();

          if (userDoc.exists) {
            friendsActivity.add({
              'user': userDoc.data(),
              'status': data['status'],
              'userScore': data['userScore'],
              'updatedAt': data['updatedAt'],
              'notes': data['notes'],
            });
          }
        }
      }

      // Sort by most recent
      friendsActivity.sort((a, b) {
        final aTime =
            (a['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final bTime =
            (b['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

      return friendsActivity;
    } catch (e) {
      print('Error getting friends activity: $e');
      return [];
    }
  }

  // Get status counts for friends
  Future<Map<String, int>> getFriendsStatusCounts(String movieId) async {
    final friendsActivity = await getFriendsActivity(movieId);

    final counts = {'planning': 0, 'watching': 0, 'completed': 0, 'dropped': 0};

    for (var activity in friendsActivity) {
      final status = activity['status'] as String?;
      if (status != null && counts.containsKey(status.toLowerCase())) {
        counts[status.toLowerCase()] = (counts[status.toLowerCase()] ?? 0) + 1;
      }
      // Count favorites as completed
      if (status == 'favourite') {
        counts['completed'] = (counts['completed'] ?? 0) + 1;
      }
    }

    return counts;
  }

  // Update user statistics
  Future<void> _updateUserStats() async {
    if (currentUserId == null) return;

    try {
      // Get all user movies
      final userMoviesSnapshot = await _firestore
          .collection('user_movies')
          .where('userId', isEqualTo: currentUserId)
          .get();

      int totalWatched = 0;
      int totalPlanning = 0;
      int totalDropped = 0;
      double totalRating = 0;
      int ratedCount = 0;

      for (var doc in userMoviesSnapshot.docs) {
        final data = doc.data();
        final status = (data['status'] as String?)?.toLowerCase();

        switch (status) {
          case 'completed':
          case 'favourite':
            totalWatched++;
            break;
          case 'planning':
            totalPlanning++;
            break;
          case 'dropped':
            totalDropped++;
            break;
        }

        final userScore = data['userScore'] as double?;
        if (userScore != null) {
          totalRating += userScore;
          ratedCount++;
        }
      }

      final averageRating = ratedCount > 0 ? totalRating / ratedCount : 0.0;

      // Get total reviews count
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Update user stats
      await _firestore.collection('users').doc(currentUserId).update({
        'stats.totalWatched': totalWatched,
        'stats.totalPlanning': totalPlanning,
        'stats.totalDropped': totalDropped,
        'stats.averageRating': averageRating,
        'stats.totalReviews': reviewsSnapshot.docs.length,
      });
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }

  // Stream user's movie status (real-time updates)
  Stream<Map<String, dynamic>?> streamUserMovieStatus(String movieId) {
    if (currentUserId == null) {
      return Stream.value(null);
    }

    final docId = '${currentUserId}_$movieId';
    return _firestore
        .collection('user_movies')
        .doc(docId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // Check if movie is in user's list
  Future<bool> isMovieInList(String movieId) async {
    if (currentUserId == null) return false;

    final docId = '${currentUserId}_$movieId';
    final doc = await _firestore.collection('user_movies').doc(docId).get();
    return doc.exists;
  }
}
