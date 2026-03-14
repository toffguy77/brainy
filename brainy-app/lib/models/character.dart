class Character {
  final String id;
  final String name;
  final String description;
  final bool isUnlocked;

  const Character({
    required this.id,
    required this.name,
    required this.description,
    this.isUnlocked = false,
  });
}
