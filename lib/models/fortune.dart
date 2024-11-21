// ************************************
// Data model for an individual fortune
// ************************************
enum FortuneType {GOOD_LUCK, BAD_LUCK}

class Fortune {
  const Fortune({required this.text, required this.type});
  final String text;
  final FortuneType type;
}