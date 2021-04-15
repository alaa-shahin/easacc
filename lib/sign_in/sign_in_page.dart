import 'package:flutter/material.dart';
import 'package:flutter_task/common_widgets/show_alert_dialog.dart';
import 'package:flutter_task/services/auth.dart';
import 'package:flutter_task/sign_in/social_sign_in_button.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({Key key, @required this.auth}) : super(key: key);
  final AuthBase auth;

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      showAlertDialog(
        context,
        title: 'Sign In Failed',
        content: e.toString(),
        cancelActionText: 'cancel',
        defaultActionText: 'OK',
      );
    }
  }

  Future<void> _signInWithFacebook(BuildContext context) async {
    try {
      await auth.signInWithFacebook();
    } catch (e) {
      showAlertDialog(
        context,
        title: 'Sign In Failed',
        content: e.toString(),
        cancelActionText: 'cancel',
        defaultActionText: 'OK',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Easacc'),
        elevation: 2.0,
      ),
      backgroundColor: Colors.grey[200],
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sign In',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 48.0),
          SocialSignInButton(
            assetsName: 'assets/images/google_logo.png',
            text: 'Sign In with Google',
            textColor: Colors.black87,
            color: Colors.white,
            onPressed: () => _signInWithGoogle(context),
          ),
          SizedBox(height: 8.0),
          SocialSignInButton(
            assetsName: 'assets/images/facebook_logo.png',
            text: 'Sign In with Facebook',
            textColor: Colors.white,
            color: Color(0xFF334D92),
            onPressed: () => _signInWithFacebook(context),
          ),
        ],
      ),
    );
  }
}
