import 'package:flutter/material.dart';
import '../screens/recipe_detail_screen.dart';
import '../models/recipe.dart'; // Import the Recipe model

class RecipeCard extends StatelessWidget {
  final Recipe recipe; // Now accepting a Recipe object instead of a Map

  RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: recipe.imageUrl.isNotEmpty
            ? Image.network(recipe.imageUrl) // Check if image URL is valid
            : Icon(Icons.food_bank), // Placeholder if image is empty
        title: Text(recipe.name), // Display recipe name
        onTap: () {
          // Navigate to the recipe detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RecipeDetailScreen(recipeId: recipe.name),
            ),
          );
        },
      ),
    );
  }
}
