import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// *********************************************
// Different categories that describes a fortune
// *********************************************
enum Categories { ROMANCE, WORK, HEALTH, ADVENTURE, GOOD_LUCK, BAD_LUCK, MISC }

// ******************************************
// METHODS
// ******************************************
// Match color to category
Color getCategoryColor(Categories category) {
  switch (category) {
    case Categories.GOOD_LUCK:
      return Colors.green;
    case Categories.HEALTH:
      return Colors.lightBlue.shade600;
    case Categories.ADVENTURE:
      return Colors.yellowAccent.shade700;
    case Categories.WORK:
      return Colors.amber.shade800;
    case Categories.ROMANCE:
      return Colors.pink;
    case Categories.BAD_LUCK:
      return Colors.red;
    default:
      return Colors.indigoAccent;
  }
}

// Match icon to category
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
      return Icons.auto_awesome;
  }
}

String getFormattedCategoryName(Categories category) {
  return category.name
      .split('_')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}

String getUnformattedCategoryName(Categories category) {
  return Categories.values.firstWhere((element) => element == category).name;
}

Categories getCategory(String name) {
  switch (name.toUpperCase()) {
    case 'ROMANCE':
      return Categories.ROMANCE;
    case 'WORK':
      return Categories.WORK;
    case 'HEALTH':
      return Categories.HEALTH;
    case 'ADVENTURE':
      return Categories.ADVENTURE;
    case 'GOOD_LUCK':
      return Categories.GOOD_LUCK;
    case 'BAD_LUCK':
      return Categories.BAD_LUCK;
    default:
      return Categories.MISC;
  }
}
