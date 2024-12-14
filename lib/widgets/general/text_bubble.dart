import 'package:csc322_starter_app/widgets/general/categories.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TextBubble extends StatelessWidget {
  TextBubble({
    super.key,
    required this.text,
    required this.textColor,
    required this.icon,
    required this.category,
    this.fontSize = 16.0,
    this.color = Colors.grey,
  });
  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;
  final Categories category;
  late IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      icon = Icons.auto_awesome;
    }

    return Container(
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
            ),
            softWrap: true,
          ),
          SizedBox(height: 10),
          Icon(icon, size: 35, color: getCategoryColor(category),),
        ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(5)),
      ),
      constraints: BoxConstraints(maxWidth: 300),
    );
  }
}
