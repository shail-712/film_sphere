import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Configure GoogleSignIn based on platform
  late final GoogleSignIn _googleSignIn;

  AuthService() {
    // Enable auth state persistence
    _enablePersistence();
    
    if (kIsWeb) {
      // For web, you MUST provide the Web Client ID
      // Get it from: Firebase Console > Project Settings > Your apps > Web app
      // Or from: Google Cloud Console > APIs & Services > Credentials
      // Format: '123456789-abc123xyz.apps.googleusercontent.com'
      
      // IMPORTANT: Replace this with your actual Web Client ID!
      const webClientId = '1072410230729-7mpqgk0nh5gci51gn8vma9kfor0dthkf.apps.googleusercontent.com'; // REPLACE THIS WITH YOUR ACTUAL CLIENT ID
      
      _googleSignIn = GoogleSignIn(
        clientId: webClientId,
        // Add these scopes for web
        scopes: <String>[
          'email',
          'profile',
        ],
      );
    } else {
      // For mobile (Android/iOS), no clientId needed
      _googleSignIn = GoogleSignIn();
    }
  }

  /// Enable auth state persistence
  Future<void> _enablePersistence() async {
    try {
      if (kIsWeb) {
        // For web, set persistence to LOCAL (survives browser restart)
        await _auth.setPersistence(Persistence.LOCAL);
      }
      // Mobile platforms have persistence enabled by default
    } catch (e) {
      print('Error enabling persistence: $e');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== GOOGLE SIGN IN ====================

  /// Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔄 Starting Google Sign-In...');
      
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ User canceled sign-in');
        return null;
      }

      print('✅ Google user selected: ${googleUser.email}');

      // Obtain auth details from the request
      print('🔄 Getting authentication details...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('✅ Access Token: ${googleAuth.accessToken?.substring(0, 20)}...');
      print('✅ ID Token: ${googleAuth.idToken?.substring(0, 20)}...');

      // Create a new credential
      print('🔄 Creating Firebase credential...');
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      print('🔄 Signing in to Firebase...');
      final userCredential = await _auth.signInWithCredential(credential);

      print('✅ Successfully signed in: ${userCredential.user?.email}');

      // Create user document if new user
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print('🔄 Creating user document for new user...');
        await _createUserDocument(userCredential.user!);
        print('✅ User document created');
      }

      return userCredential;
    } catch (e, stackTrace) {
      print('❌ Error signing in with Google: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  // ==================== EMAIL/PASSWORD SIGN IN ====================

  /// Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(username);

      // Create user document
      await _createUserDocument(userCredential.user!, username: username);

      return userCredential;
    } catch (e) {
      print('Error signing up: $e');
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error sending password reset email: $e');
      rethrow;
    }
  }

  // ==================== SIGN OUT ====================

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // ==================== USER MANAGEMENT ====================

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user, {String? username}) async {
    final userDoc = _firestore.collection('users').doc(user.uid);

    // Check if document already exists
    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) return;

    // Create new user document
    await userDoc.set({
      'username': username ?? user.displayName ?? 'User${user.uid.substring(0, 6)}',
      'displayName': user.displayName ?? username ?? 'User',
      'email': user.email,
      'profileImageUrl': user.photoURL ?? '',
      'bio': '',
      'createdAt': FieldValue.serverTimestamp(),
      'stats': {
        'totalWatched': 0,
        'totalPlanning': 0,
        'totalDropped': 0,
        'averageRating': 0.0,
        'totalReviews': 0,
        'followersCount': 0,
        'followingCount': 0,
      },
    });
  }

  /// Get user document
  Future<Map<String, dynamic>?> getUserDocument(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return {...doc.data()!, 'id': doc.id};
      }
      return null;
    } catch (e) {
      print('Error getting user document: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? bio,
    String? profileImageUrl,
  }) async {
    if (currentUser == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (profileImageUrl != null) updates['profileImageUrl'] = profileImageUrl;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(currentUser!.uid).update(updates);
    }

    // Update Firebase Auth profile
    if (displayName != null) {
      await currentUser!.updateDisplayName(displayName);
    }
    if (profileImageUrl != null) {
      await currentUser!.updatePhotoURL(profileImageUrl);
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Get user-friendly error message
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'weak-password':
          return 'Password is too weak. Use at least 6 characters.';
        case 'operation-not-allowed':
          return 'This sign-in method is not enabled.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return 'Network error. Check your connection.';
        default:
          return 'An error occurred: ${error.message}';
      }
    }
    return 'An unexpected error occurred.';
  }
}