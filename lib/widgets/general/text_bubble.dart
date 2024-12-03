import 'package:flutter/material.dart';

class TextBubble extends StatelessWidget {
  const TextBubble(
      {super.key,
      required this.text,
      required this.textColor,
      this.fontSize = 16.0,
      this.color = Colors.grey});
  final String text;
  final Color color;
  final Color textColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Container(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
          softWrap: true,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
        constraints: BoxConstraints(maxWidth: 300),
      ),
    );
  }
}
