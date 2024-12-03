// ************************************
// Data model for an individual fortune
// ************************************
import 'package:csc322_starter_app/widgets/general/categories.dart';

class Fortune {
  const Fortune({required this.text, required this.category, required this.id});
  final String text;
  final Categories category;
  final String id;
}