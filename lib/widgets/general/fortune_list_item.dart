import 'package:csc322_starter_app/widgets/general/categories.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// *******************************************************
// An individual fortune to be displayed in a list viewer
// *******************************************************
class FortuneListItem extends ListTile {
  const FortuneListItem(
      {super.key, required this.text, required this.category});
  final String text;
  final Categories category;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        '$text',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
      leading: Icon(
        getCategoryIcon(category),
        color: Theme.of(context).colorScheme.onPrimary,
        size: 30,
      ),
      tileColor: getCategoryColor(category),
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
