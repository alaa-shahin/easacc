import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class AuthBase {
  User get currentUser;

  Future<void> signOut();

  Stream<User> authStateChange();

  Future<User> signInWithFacebook();

  Future signInWithGoogle();

  Future setSettings(String uid, Map<String, dynamic> data);

  Future getSettings(String uid);
}

class Auth implements AuthBase {
  final _auth = FirebaseAuth.instance;

  User get currentUser => _auth.currentUser;

  @override
  Stream<User> authStateChange() => _auth.authStateChanges();

  @override
  Future<User> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken != null) {
        final userCredential = await _auth.signInWithCredential(
          GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          ),
        );
        return userCredential.user;
      } else {
        throw FirebaseAuthException(
          code: 'ERROR_MISSING_GOOGLE_ID_TOKEN',
          message: 'Missing Google ID Token',
        );
      }
    } else {
      throw FirebaseAuthException(
        code: 'ERROR_ABORTED_BY_USER',
        message: 'Sign In Aborted by User',
      );
    }
  }

  @override
  Future<User> signInWithFacebook() async {
    final fb = FacebookLogin();
    final response = await fb.logIn(permissions: [
      FacebookPermission.email,
      FacebookPermission.publicProfile
    ]);
    switch (response.status) {
      case FacebookLoginStatus.success:
        final accessToken = response.accessToken;
        final userCredential = await _auth.signInWithCredential(
            FacebookAuthProvider.credential(accessToken.token));
        return userCredential.user;
      case FacebookLoginStatus.cancel:
        throw FirebaseAuthException(
          code: 'ERROR_ABORTED_BY_USER',
          message: 'Sign In Aborted by User',
        );
      case FacebookLoginStatus.error:
        throw FirebaseAuthException(
          code: 'ERROR_FACEBOOK_LOGIN_FAILED',
          message: response.error.developerMessage,
        );
      default:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> signOut() async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    final fb = FacebookLogin();
    await fb.logOut();
    await _auth.signOut();
  }

  @override
  Future setSettings(String uid, Map<String, dynamic> data) async {
    final String path = '/settings/$uid';
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data);
  }

  @override
  Future getSettings(String uid) async {
    final String path = '/settings/$uid';
    final reference = FirebaseFirestore.instance.doc(path);
    DocumentSnapshot docs = await reference.get();
    return docs;
  }
}
