import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// *********************************************
// Different categories that describes a fortune
// *********************************************
enum Categories { ROMANCE, WORK, HEALTH, ADVENTURE, GOOD_LUCK, BAD_LUCK }

// ******************************************
// METHODS
// ******************************************
// Match color to category
Color getCategoryColor(Categories category) {
  switch (category) {
    case Categories.GOOD_LUCK:
      return Colors.blue.shade300;
    case Categories.HEALTH:
      return Colors.lightGreen;
    case Categories.ADVENTURE:
      return Colors.yellow.shade400;
    case Categories.WORK:
      return Colors.orange.shade400;
    case Categories.ROMANCE:
      return Colors.pink.shade400;
    case Categories.BAD_LUCK:
      return Colors.red.shade600;
    default:
      return Colors.grey;
  }
}

// Match color to Icon
IconData getCategoryIcon(Categories category) {
  switch (category) {
    case Categories.GOOD_LUCK:
      return FontAwesomeIcons.clover;
    case Categories.HEALTH:
      return FontAwesomeIcons.squarePlus;
    case Categories.ADVENTURE:
      return FontAwesomeIcons.personHiking;
    case Categories.WORK:
      return FontAwesomeIcons.briefcase;
    case Categories.ROMANCE:
      return FontAwesomeIcons.heart;
    case Categories.BAD_LUCK:
      return FontAwesomeIcons.cat;
    default:
      return FontAwesomeIcons.comment;
  }
}

String getCategoryName(Categories category) {
  return category.name
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
