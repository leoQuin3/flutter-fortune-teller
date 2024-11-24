import 'package:csc322_starter_app/models/fortune.dart';
import 'package:flutter/material.dart';

// ***********************************************
// An individual fortune to be displayed on screen
// ***********************************************
class FortuneListItem extends ListTile {
  const FortuneListItem({super.key, required this.text, required this.type});
  final String text;
  final FortuneType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('$text',
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
      leading: Icon(
        Icons.auto_awesome,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
      tileColor: type == FortuneType.BAD_LUCK
          ? Colors.red.shade700
          : Colors.greenAccent.shade700,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(6)),
    );
  }
}
