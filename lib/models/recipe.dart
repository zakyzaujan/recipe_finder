class Recipe {
  final String name;
  final String imageUrl;
  final String category;
  final String area;
  final String instructions;

  Recipe({
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.area,
    required this.instructions,
  });

  // Factory method for creating a Recipe from a map
  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      name: map['strMeal'] ?? 'No Name',
      imageUrl: map['strMealThumb'] ?? '',
      category: map['strCategory'] ?? 'N/A',
      area: map['strArea'] ?? 'N/A',
      instructions: map['strInstructions'] ?? 'No instructions available.',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe &&
        other.name == name &&
        other.imageUrl == imageUrl &&
        other.category == category &&
        other.area == area &&
        other.instructions == instructions;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        imageUrl.hashCode ^
        category.hashCode ^
        area.hashCode ^
        instructions.hashCode;
  }
}
