import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Untuk encoding/decoding JSON
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  RecipeDetailScreen({required this.recipeId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<Map<String, dynamic>> recipeDetails;
  late Map<String, dynamic> bookmarkedRecipe;
  bool isBookmarked = false;

  @override
  void initState() {
    super.initState();
    recipeDetails = _fetchRecipeDetails(widget.recipeId);
    bookmarkedRecipe = {};
    _checkIfBookmarked();
  }

  Future<Map<String, dynamic>> _fetchRecipeDetails(String recipeId) async {
    return await ApiService().fetchRecipeDetails(recipeId);
  }

  List<Map<String, String>> getIngredients(Map<String, dynamic> recipe) {
    List<Map<String, String>> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredient = recipe['strIngredient$i'];
      final measure = recipe['strMeasure$i'];

      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add({
          'ingredient': ingredient,
          'measure': measure ?? '',
        });
      }
    }

    return ingredients;
  }

  Future<void> _checkIfBookmarked() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRecipes = prefs.getString('bookmarkedRecipes');
    if (storedRecipes != null) {
      List<dynamic> bookmarkedRecipes = json.decode(storedRecipes);
      for (var recipe in bookmarkedRecipes) {
        if (recipe['idMeal'] == widget.recipeId) {
          setState(() {
            bookmarkedRecipe = recipe;
            isBookmarked = true;
          });
        }
      }
    }
  }

  Future<void> _bookmarkRecipe(Map<String, dynamic> recipe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRecipes = prefs.getString('bookmarkedRecipes');
    List<dynamic> bookmarkedRecipes =
        storedRecipes != null ? json.decode(storedRecipes) : [];

    if (bookmarkedRecipes.any((item) => item['idMeal'] == recipe['idMeal'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep sudah ada di bookmark')),
      );
    } else {
      bookmarkedRecipes.add(recipe);
      await prefs.setString(
          'bookmarkedRecipes', json.encode(bookmarkedRecipes));
      setState(() {
        isBookmarked = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep ditambahkan ke bookmark')),
      );
    }
  }

  Future<void> _removeBookmark(String recipeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRecipes = prefs.getString('bookmarkedRecipes');
    if (storedRecipes != null) {
      List<dynamic> bookmarkedRecipes = json.decode(storedRecipes);
      bookmarkedRecipes.removeWhere((item) => item['idMeal'] == recipeId);
      await prefs.setString(
          'bookmarkedRecipes', json.encode(bookmarkedRecipes));
      setState(() {
        isBookmarked = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep dihapus dari bookmark')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222222), // Tema gelap
      appBar: AppBar(
        title: Text(
          'Detail Resep',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF1E1E1E),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: recipeDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recipe = snapshot.data ?? bookmarkedRecipe;
          final ingredients = getIngredients(recipe);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recipe['strMealThumb'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      recipe['strMealThumb']!,
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 16),

                // Category Section
                Row(
                  children: [
                    Icon(Icons.category, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Kategori: ${recipe['strCategory'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Area Section
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Asal: ${recipe['strArea'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Ingredients Section
                Text(
                  'Bahan-bahan:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: ingredients.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['ingredient']}: ${item['measure']}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),

                // Instructions Section in a Card
                Text(
                  'Instruksi:',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Card(
                  color: Color(0xFF333333), // Warna Card gelap
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      recipe['strInstructions'] ?? 'No instructions available.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
