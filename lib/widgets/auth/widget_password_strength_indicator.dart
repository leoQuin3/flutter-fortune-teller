// -----------------------------------------------------------------------
// Filename: password_strength_indicator.dart
// Original Author: Dan Grissom
// Creation Date: 5/22/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains the model for the user profile

////////////////////////////////////////////////////////////////////////////////////////////
// Imports
////////////////////////////////////////////////////////////////////////////////////////////
// Dart imports
import 'package:flutter/material.dart';

// App relative file imports
import '../../theme/colors.dart';

//////////////////////////////////////////////////////////////////
// StateFUL widget which manages state. Simply initializes the
// state object.
//////////////////////////////////////////////////////////////////

class WidgetPasswordStrengthIndicator extends StatefulWidget {
  WidgetPasswordStrengthIndicator({
    super.key,
    required this.passwordStrength,
    required this.passwordColor,
    required this.passwordText,
  });
  double passwordStrength;
  Color passwordColor;
  String passwordText;
  @override
  State<WidgetPasswordStrengthIndicator> createState() => _WidgetPasswordStrengthIndicatorState();
}

double getPasswordStrength(String password) {
  int strength = 0;
  if (password.length >= 6) {
    strength++;
  }
  if (RegExp(r"(?=.*[a-z])").hasMatch(password)) {
    strength++;
  }
  if (RegExp(r"(?=.*[A-Z])").hasMatch(password)) {
    strength++;
  }
  if (RegExp(r"(?=.*\d)").hasMatch(password)) {
    strength++;
  }
  if (RegExp(r"(?=.*[!@#$%^&*(),.?:{}|<>])").hasMatch(password)) {
    strength++;
  }
  return strength / 5;
}

String getPasswordStrengthText(double passwordStrength) {
  if (passwordStrength == 0) {
    return "Weak";
  } else if (passwordStrength == .2) {
    return "Weak";
  } else if (passwordStrength == .4) {
    return "Fair";
  } else if (passwordStrength == .6) {
    return "Good";
  } else if (passwordStrength == .8) {
    return "Strong";
  } else {
    return "Very Strong";
  }
}

Color getPasswordStrengthColor(double passwordStrength) {
  if (passwordStrength == 0) {
    return CustomColors.statusError;
  } else if (passwordStrength == .2) {
    return CustomColors.statusError;
  } else if (passwordStrength == .4) {
    return CustomColors.statusWarning;
  } else if (passwordStrength == .6) {
    return CustomColors.statusSuccess;
  } else if (passwordStrength == .8) {
    return CustomColors.statusSuccess;
  } else {
    return CustomColors.statusSuccess;
  }
}

//////////////////////////////////////////////////////////////////
// The actual STATE which is managed by the above widget.
//////////////////////////////////////////////////////////////////
class _WidgetPasswordStrengthIndicatorState extends State<WidgetPasswordStrengthIndicator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 10,
          width: MediaQuery.of(context).size.width * 1.00,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(20),
            value: widget.passwordStrength,
            backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
            valueColor: AlwaysStoppedAnimation<Color>(widget.passwordColor),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            widget.passwordText,
            style: TextStyle(color: widget.passwordColor, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
