import 'package:flutter/material.dart';


// ***********************************************
// An individual fortune to be displayed on screen
// ***********************************************
class FortuneListItem extends ListTile {
  const FortuneListItem({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('$text'),
      leading: Icon(Icons.bubble_chart),
      tileColor: Colors.blue[600],
      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}