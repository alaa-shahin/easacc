import 'package:flutter/material.dart';
import 'package:flutter_task/common_widgets/custom_raised_button.dart';

class SocialSignInButton extends CustomRaisedButton {
  SocialSignInButton({
    @required String assetsName,
    @required String text,
    Color color,
    Color textColor,
    VoidCallback onPressed,
  })  : assert(assetsName != null),
        assert(text != null),
        super(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(assetsName, height: 35),
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                ),
              ),
              Opacity(
                opacity: 0.0,
                child: Image.asset(assetsName, height: 35),
              ),
            ],
          ),
          color: color,
          onPressed: onPressed,
        );
}
