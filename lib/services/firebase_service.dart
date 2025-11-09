import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // ==================== USER MOVIES ====================
  
  /// Add or update a movie in user's list
  Future<void> addMovieToList({
    required int movieId,
    required String movieTitle,
    required String moviePosterPath,
    String? movieBackdropPath,
    required String movieGenre,
    required int movieYear,
    required double movieRating,
    required String status,
    double? userScore,
    bool isFavourite = false,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}__$movieId';
    final now = Timestamp.now();
    
    // FIXED: Never use 'favourite' as status, always use 'completed' with isFavourite flag
    final actualStatus = status == 'favourite' ? 'completed' : status.toLowerCase();
    final isActuallyFavourite = status == 'favourite' || isFavourite;
    
    final data = {
      'userId': currentUserId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'movieBackdropPath': movieBackdropPath,
      'movieGenre': movieGenre,
      'movieYear': movieYear,
      'movieRating': movieRating,
      'status': actualStatus,
      'userScore': userScore,
      'isFavourite': isActuallyFavourite,
      'updatedAt': now,
    };

    // If adding to completed (including favourites), set completedAt
    if (actualStatus == 'completed') {
      data['completedAt'] = now;
    }

    // Check if document exists
    final docSnapshot = await _firestore.collection('user_movies').doc(docId).get();
    
    if (!docSnapshot.exists) {
      data['addedAt'] = now;
    }

    await _firestore.collection('user_movies').doc(docId).set(
      data,
      SetOptions(merge: true),
    );

    // Update user stats
    await _updateUserStats();
  }

 /// Get user's movies by status
Stream<List<Map<String, dynamic>>> getUserMoviesByStatus(String status) {
  if (currentUserId == null) return Stream.value([]);

  Query query = _firestore
      .collection('user_movies')
      .where('userId', isEqualTo: currentUserId);

  if (status == 'favourite') {
    // FIXED: Query for completed movies with isFavourite = true
    query = query
        .where('status', isEqualTo: 'completed')
        .where('isFavourite', isEqualTo: true);
  } else if (status == 'completed') {
    // Show all completed movies (including favourites)
    query = query.where('status', isEqualTo: 'completed');
  } else if (status != 'all') {
    query = query.where('status', isEqualTo: status);
  }

  return query.orderBy('addedAt', descending: true).snapshots().map(
    (snapshot) => snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList(),
  );
}

  /// Get a specific user movie
  Future<Map<String, dynamic>?> getUserMovie(int movieId) async {
    if (currentUserId == null) return null;

    final docId = '${currentUserId}__$movieId';
    final doc = await _firestore.collection('user_movies').doc(docId).get();
    
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Remove movie from user's list
  Future<void> removeMovieFromList(int movieId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}__$movieId';
    await _firestore.collection('user_movies').doc(docId).delete();
    await _updateUserStats();
  }

  /// Update movie score
  Future<void> updateMovieScore(int movieId, double score) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final docId = '${currentUserId}__$movieId';
    await _firestore.collection('user_movies').doc(docId).update({
      'userScore': score,
      'updatedAt': Timestamp.now(),
    });
    await _updateUserStats();
  }

  // ==================== REVIEWS ====================

  /// Create a review
  Future<String> createReview({
    required int movieId,
    required String movieTitle,
    required String moviePosterPath,
    required String reviewText,
    required double reviewScore,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final reviewData = {
      'userId': currentUserId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterPath': moviePosterPath,
      'reviewText': reviewText,
      'reviewScore': reviewScore,
      'likesCount': 0,
      'dislikesCount': 0,
      'commentsCount': 0,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(),
    };

    final docRef = await _firestore.collection('reviews').add(reviewData);
    
    // Update user stats
    await _firestore.collection('users').doc(currentUserId).update({
      'stats.totalReviews': FieldValue.increment(1),
    });

    return docRef.id;
  }

  /// Get reviews for a movie
  Stream<List<Map<String, dynamic>>> getMovieReviews(int movieId) {
    return _firestore
        .collection('reviews')
        .where('movieId', isEqualTo: movieId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Get user's reviews
  Stream<List<Map<String, dynamic>>> getUserReviews(String userId) {
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Like/Unlike a review
  Future<void> toggleReviewInteraction(
    String reviewId,
    String interactionType,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final interactionId = '${reviewId}__$currentUserId';
    final interactionRef = _firestore
        .collection('review_interactions')
        .doc(interactionId);

    final interactionDoc = await interactionRef.get();

    if (interactionDoc.exists) {
      final existingType = interactionDoc.data()!['interactionType'];
      
      if (existingType == interactionType) {
        // Remove interaction
        await interactionRef.delete();
        await _firestore.collection('reviews').doc(reviewId).update({
          '${interactionType}sCount': FieldValue.increment(-1),
        });
      } else {
        // Change interaction type
        await interactionRef.update({
          'interactionType': interactionType,
          'createdAt': Timestamp.now(),
        });
        await _firestore.collection('reviews').doc(reviewId).update({
          '${existingType}sCount': FieldValue.increment(-1),
          '${interactionType}sCount': FieldValue.increment(1),
        });
      }
    } else {
      // Add new interaction
      await interactionRef.set({
        'reviewId': reviewId,
        'userId': currentUserId,
        'interactionType': interactionType,
        'createdAt': Timestamp.now(),
      });
      await _firestore.collection('reviews').doc(reviewId).update({
        '${interactionType}sCount': FieldValue.increment(1),
      });
    }
  }

  /// Get user's interaction with a review
  Future<String?> getReviewInteraction(String reviewId) async {
    if (currentUserId == null) return null;

    final interactionId = '${reviewId}__$currentUserId';
    final doc = await _firestore
        .collection('review_interactions')
        .doc(interactionId)
        .get();

    return doc.exists ? doc.data()!['interactionType'] : null;
  }

  /// Add comment to review
  Future<String> addReviewComment(String reviewId, String commentText) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final username = userDoc.data()?['username'] ?? 'Unknown';

    final commentData = {
      'reviewId': reviewId,
      'userId': currentUserId,
      'username': username,
      'commentText': commentText,
      'likesCount': 0,
      'dislikesCount': 0,
      'createdAt': Timestamp.now(),
    };

    final docRef = await _firestore.collection('review_comments').add(commentData);

    // Increment comment count
    await _firestore.collection('reviews').doc(reviewId).update({
      'commentsCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  /// Get review comments
  Stream<List<Map<String, dynamic>>> getReviewComments(String reviewId) {
    return _firestore
        .collection('review_comments')
        .where('reviewId', isEqualTo: reviewId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  // ==================== SOCIAL POSTS ====================

  /// Create a social post
  Future<String> createSocialPost({
    required String postText,
    String postType = 'text',
    int? movieId,
    String? reviewId,
  }) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final userData = userDoc.data()!;

    final postData = {
      'userId': currentUserId,
      'username': userData['username'],
      'userProfileImage': userData['profileImageUrl'] ?? '',
      'postText': postText,
      'postType': postType,
      'movieId': movieId,
      'reviewId': reviewId,
      'likesCount': 0,
      'dislikesCount': 0,
      'commentsCount': 0,
      'createdAt': Timestamp.now(),
    };

    final docRef = await _firestore.collection('social_posts').add(postData);

    // Add to followers' feeds
    await _addPostToFollowerFeeds(docRef.id);

    return docRef.id;
  }

  /// Get social feed (all posts)
  Stream<List<Map<String, dynamic>>> getSocialFeed() {
    return _firestore
        .collection('social_posts')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Get following feed (only followed users)
  Stream<List<Map<String, dynamic>>> getFollowingFeed() async* {
    if (currentUserId == null) {
      yield [];
      return;
    }

    // Get list of users the current user follows
    final followingSnapshot = await _firestore
        .collection('followers')
        .where('followerId', isEqualTo: currentUserId)
        .get();

    final followingIds = followingSnapshot.docs
        .map((doc) => doc.data()['followingId'] as String)
        .toList();

    if (followingIds.isEmpty) {
      yield [];
      return;
    }

    // Firestore 'in' queries are limited to 10 items
    // For more, you'd need to batch or use a different approach
    final batchSize = 10;
    final batches = <Future<QuerySnapshot>>[];

    for (var i = 0; i < followingIds.length; i += batchSize) {
      final batch = followingIds.skip(i).take(batchSize).toList();
      batches.add(
        _firestore
            .collection('social_posts')
            .where('userId', whereIn: batch)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get(),
      );
    }

    final results = await Future.wait(batches);
    final allDocs = results.expand((snapshot) => snapshot.docs).toList();
    
    // Sort all documents by createdAt
    allDocs.sort((a, b) {
      final aData = a.data() as Map<String, dynamic>?;
      final bData = b.data() as Map<String, dynamic>?;
      
      final aTime = (aData?['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
      final bTime = (bData?['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
      
      return bTime.compareTo(aTime);
    });

    yield allDocs.map((doc) {
      final data = doc.data() as Map<String, dynamic>? ?? {};
      return <String, dynamic>{...data, 'id': doc.id};
    }).toList();
  }

  /// Toggle post interaction
  Future<void> togglePostInteraction(
    String postId,
    String interactionType,
  ) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final interactionId = '${postId}__$currentUserId';
    final interactionRef = _firestore
        .collection('post_interactions')
        .doc(interactionId);

    final interactionDoc = await interactionRef.get();

    if (interactionDoc.exists) {
      final existingType = interactionDoc.data()!['interactionType'];
      
      if (existingType == interactionType) {
        await interactionRef.delete();
        await _firestore.collection('social_posts').doc(postId).update({
          '${interactionType}sCount': FieldValue.increment(-1),
        });
      } else {
        await interactionRef.update({
          'interactionType': interactionType,
          'createdAt': Timestamp.now(),
        });
        await _firestore.collection('social_posts').doc(postId).update({
          '${existingType}sCount': FieldValue.increment(-1),
          '${interactionType}sCount': FieldValue.increment(1),
        });
      }
    } else {
      await interactionRef.set({
        'postId': postId,
        'userId': currentUserId,
        'interactionType': interactionType,
        'createdAt': Timestamp.now(),
      });
      await _firestore.collection('social_posts').doc(postId).update({
        '${interactionType}sCount': FieldValue.increment(1),
      });
    }
  }

  /// Add comment to post
  Future<String> addPostComment(String postId, String commentText) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final userDoc = await _firestore.collection('users').doc(currentUserId).get();
    final username = userDoc.data()?['username'] ?? 'Unknown';

    final commentData = {
      'postId': postId,
      'userId': currentUserId,
      'username': username,
      'commentText': commentText,
      'likesCount': 0,
      'dislikesCount': 0,
      'createdAt': Timestamp.now(),
    };

    final docRef = await _firestore.collection('post_comments').add(commentData);

    await _firestore.collection('social_posts').doc(postId).update({
      'commentsCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  // ==================== FOLLOWERS ====================

  /// Follow a user
  Future<void> followUser(String userId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final followId = '${currentUserId}__$userId';
    
    await _firestore.collection('followers').doc(followId).set({
      'followerId': currentUserId,
      'followingId': userId,
      'createdAt': Timestamp.now(),
    });

    // Update follower/following counts
    await _firestore.collection('users').doc(currentUserId).update({
      'stats.followingCount': FieldValue.increment(1),
    });
    await _firestore.collection('users').doc(userId).update({
      'stats.followersCount': FieldValue.increment(1),
    });
  }

  /// Unfollow a user
  Future<void> unfollowUser(String userId) async {
    if (currentUserId == null) throw Exception('User not authenticated');

    final followId = '${currentUserId}__$userId';
    
    await _firestore.collection('followers').doc(followId).delete();

    await _firestore.collection('users').doc(currentUserId).update({
      'stats.followingCount': FieldValue.increment(-1),
    });
    await _firestore.collection('users').doc(userId).update({
      'stats.followersCount': FieldValue.increment(-1),
    });
  }

  /// Check if following a user
  Future<bool> isFollowing(String userId) async {
    if (currentUserId == null) return false;

    final followId = '${currentUserId}__$userId';
    final doc = await _firestore.collection('followers').doc(followId).get();
    return doc.exists;
  }

  /// Get followers
  Stream<List<Map<String, dynamic>>> getFollowers(String userId) {
    return _firestore
        .collection('followers')
        .where('followingId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final followers = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final followerId = doc.data()['followerId'];
        final userDoc = await _firestore.collection('users').doc(followerId).get();
        if (userDoc.exists) {
          followers.add({...userDoc.data()!, 'id': userDoc.id});
        }
      }
      return followers;
    });
  }

  /// Get following
  Stream<List<Map<String, dynamic>>> getFollowing(String userId) {
    return _firestore
        .collection('followers')
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      final following = <Map<String, dynamic>>[];
      for (var doc in snapshot.docs) {
        final followingId = doc.data()['followingId'];
        final userDoc = await _firestore.collection('users').doc(followingId).get();
        if (userDoc.exists) {
          following.add({...userDoc.data()!, 'id': userDoc.id});
        }
      }
      return following;
    });
  }

  // ==================== HELPER METHODS ====================

/// Update user statistics (FIXED version)
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
      final status = data['status'];
      
      // FIXED: Count completed movies (favourites are also completed)
      if (status == 'completed') {
        totalWatched++;
      } else if (status == 'planning') {
        totalPlanning++;
      } else if (status == 'dropped') {
        totalDropped++;
      }

      if (data['userScore'] != null) {
        totalRating += data['userScore'];
        ratedCount++;
      }
    }

    await _firestore.collection('users').doc(currentUserId).update({
      'stats.totalWatched': totalWatched,
      'stats.totalPlanning': totalPlanning,
      'stats.totalDropped': totalDropped,
      'stats.averageRating': ratedCount > 0 ? totalRating / ratedCount : 0,
    });
  } catch (e) {
    print('Error updating user stats: $e');
  }
}

  /// Add post to followers' feeds (for feed cache optimization)
  Future<void> _addPostToFollowerFeeds(String postId) async {
    if (currentUserId == null) return;

    final followersSnapshot = await _firestore
        .collection('followers')
        .where('followingId', isEqualTo: currentUserId)
        .get();

    final batch = _firestore.batch();

    for (var doc in followersSnapshot.docs) {
      final followerId = doc.data()['followerId'];
      final cacheDocId = '${followerId}__$postId';
      
      batch.set(
        _firestore.collection('user_feed_cache').doc(cacheDocId),
        {
          'userId': followerId,
          'postId': postId,
          'postCreatedAt': Timestamp.now(),
          'postAuthorId': currentUserId,
        },
      );
    }

    await batch.commit();
  }

  /// Get post comments
  Stream<List<Map<String, dynamic>>> getPostComments(String postId) {
    return _firestore
        .collection('post_comments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList(),
        );
  }

  /// Get user's interaction with a post
  Future<String?> getPostInteraction(String postId) async {
    if (currentUserId == null) return null;

    final interactionId = '${postId}__$currentUserId';
    final doc = await _firestore
        .collection('post_interactions')
        .doc(interactionId)
        .get();

    return doc.exists ? doc.data()!['interactionType'] : null;
  }

  /// Search users by username or display name
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();

    // Search by username
    final usernameSnapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('username', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .limit(20)
        .get();

    // Search by display name
    final displayNameSnapshot = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: lowercaseQuery)
        .where('displayName', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
        .limit(20)
        .get();

    final users = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    // Combine results and remove duplicates
    for (var doc in [...usernameSnapshot.docs, ...displayNameSnapshot.docs]) {
      if (!seenIds.contains(doc.id) && doc.id != currentUserId) {
        seenIds.add(doc.id);
        users.add({...doc.data(), 'id': doc.id});
      }
    }

    return users;
  }

  /// Get user profile by ID
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return {...doc.data()!, 'id': doc.id};
    }
    return null;
  }

  /// Get follower count
  Future<int> getFollowerCount(String userId) async {
    final snapshot = await _firestore
        .collection('followers')
        .where('followingId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }

  /// Get following count
  Future<int> getFollowingCount(String userId) async {
    final snapshot = await _firestore
        .collection('followers')
        .where('followerId', isEqualTo: userId)
        .get();
    return snapshot.docs.length;
  }
}

