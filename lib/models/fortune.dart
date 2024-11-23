// ************************************
// Data model for an individual fortune
// ************************************
import 'package:uuid/uuid.dart';

enum FortuneType {GOOD_LUCK, BAD_LUCK}

class Fortune {
  const Fortune({required this.text, required this.type, required this.id});
  final String text;
  final FortuneType type;
  final String id;
}