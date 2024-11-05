// -----------------------------------------------------------------------
// Filename: popup_dialogue.dart
// Original Author: Dan Grissom
// Creation Date: 5/21/2024
// Copyright: (c) 2024 CSC322
// Description: This file contains a wrapper around the Flutter alert
//              dialogue library to display messages to the user.

//////////////////////////////////////////////////////////////////////////
// Imports
//////////////////////////////////////////////////////////////////////////
// Flutter external package imports
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// App relative file imports

//////////////////////////////////////////////////////////////////
// Class definition for PopupDialogue. This is essentially a
// wrapper around the AlertDialog library and the required scaffolding
// to get that working.
//////////////////////////////////////////////////////////////////
class PopupDialogue {
  //////////////////////////////////////////////////////////////////
  // This method shows a Yes/No alert dialog to confirm a user
  // action. Returns TRUE if user selected YES; FALSE if user selected
  // NO.
  //////////////////////////////////////////////////////////////////
  static Future<bool?> showConfirm(String question, BuildContext context, {String title = "Confirm"}) async {
    bool confirmed = false;
    return popupStyle(
      context: context,
      title: title,
      content: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Yes"),
          onPressed: () {
            confirmed = true;
            Navigator.of(context).pop(confirmed); // Use Navigator to pop safely
          },
        ),
        TextButton(
          child: const Text('No'),
          onPressed: () {
            Navigator.of(context).pop(confirmed); // Use Navigator to pop safely
          },
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////////
  // This method shows a Yes/No alert dialog to confirm a user
  // action. Returns TRUE if user selected YES; FALSE if user selected
  // NO.
  //////////////////////////////////////////////////////////////////
  static Future<String?> showSave(String question, BuildContext context, {String title = "Confirm"}) async {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                question,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter meeting name',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(_controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<bool?> popupStyle(
      {required Widget content, required String title, required List<Widget> actions, required BuildContext context}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          titlePadding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          title: Column(
            children: [
              Row(
                children: [
                  Image.asset(
                    "images/logo.png",
                    height: 35,
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 5),
                      child: Text(title),
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Divider(
                  thickness: 1,
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: content,
          actions: actions,
        );
      },
    );
  }

  //////////////////////////////////////////////////////////////////
  // This method shows a Yes/No alert dialog to confirm a user
  // action. Returns TRUE if user selected YES; FALSE if user selected
  // NO.
  //////////////////////////////////////////////////////////////////
  static Future<bool?> showOkay(String message, BuildContext context, {String title = "Message"}) async {
    bool confirmed = false;
    return popupStyle(
      context: context,
      title: title,
      content: Text(
        message,
        style: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 18,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            confirmed = true;
            context.pop(confirmed);
          },
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////////
  // This method shows an "OK" alert dialog to confirm a user has seen
  // a message. Returns true if user clicks OK; false otherwise.
  //////////////////////////////////////////////////////////////////
  static Future<bool?> showCustomOkay(String title, BuildContext context, {required Widget content}) async {
    bool confirmed = false;
    return popupStyle(
      context: context,
      title: title,
      content: content,
      actions: <Widget>[
        TextButton(
          child: const Text("OK"),
          onPressed: () {
            confirmed = true;
            context.pop(confirmed);
          },
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////////
  // This function takes in a message type, message, message
  // origin (from frames or from phone) and local context and
  // displays a snackbar with the appropriate message, color and
  // source icon.
  //////////////////////////////////////////////////////////////////
  static showTextField(String title, String field1Label, BuildContext context, Function(String) callback,
      {String? buttonText, String? description, Function(String)? onChanged, String? defaultValue}) {
    // Declare initial controls
    final field1TextController = TextEditingController();
    field1TextController.text = defaultValue ?? "";
    return popupStyle(
      context: context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (description != null) Text(description),
          Padding(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 15.0,
            ),
            child: TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (newValue) {
                if (onChanged != null) {
                  onChanged(newValue);
                }
              },
              onTapOutside: (value) {},
              validator: (value) {
                if (value == null || value.isEmpty || !value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: field1Label),
              controller: field1TextController,
            ),
          ),
          ElevatedButton(
            onPressed: () => callback(field1TextController.text),
            child: Text(buttonText ?? "Submit"),
          ),
        ],
      ),
      actions: [],
    );
  }
}
