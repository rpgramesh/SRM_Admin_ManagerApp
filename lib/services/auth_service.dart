import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // For web, use signInSilently first, then fallback to signIn
      if (kIsWeb) {
        // Try silent sign in first
        final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
        if (googleUser != null) {
          return await _signInWithGoogleAccount(googleUser);
        }
        
        // If silent sign in fails, use regular sign in
        final GoogleSignInAccount? googleUserSignIn = await _googleSignIn.signIn();
        if (googleUserSignIn != null) {
          return await _signInWithGoogleAccount(googleUserSignIn);
        }
      } else {
        // For mobile, use the regular sign in flow
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser != null) {
          return await _signInWithGoogleAccount(googleUser);
        }
      }
      
      // User canceled the sign-in flow
      return null;
    } catch (error) {
      print('Error signing in with Google: $error');
      return null;
    }
  }

  // Helper method to sign in with Google account
  Future<User?> _signInWithGoogleAccount(GoogleSignInAccount googleUser) async {
    try {
      // Obtain the auth details from the Google Sign-In
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      return authResult.user;
    } catch (error) {
      print('Error signing in with Google account: $error');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (error) {
      print('Error signing out: $error');
    }
  }
}