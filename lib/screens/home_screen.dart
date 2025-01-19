import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _recipes = [];
  List<String> _ingredients = [];
  List<dynamic> _bookmarkedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarkedRecipes();
  }

  Future<void> _loadBookmarkedRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedRecipes = prefs.getString('bookmarkedRecipes');
    if (storedRecipes != null) {
      setState(() {
        _bookmarkedRecipes = json.decode(storedRecipes);
      });
    }
  }

  Future<void> _bookmarkRecipe(Map<String, dynamic> recipe) async {
    // Mengecek apakah resep sudah ada di boookmark
    if (_bookmarkedRecipes.any((item) => item['idMeal'] == recipe['idMeal'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep sudah ada di bookmark')),
      );
    } else {
      setState(() {
        _bookmarkedRecipes.add(recipe);
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      // Menyimpan resep dalam string (JSON encoded)
      await prefs.setString(
          'bookmarkedRecipes', json.encode(_bookmarkedRecipes));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resep ditambahkan ke bookmark')),
      );
    }
  }

  _removeBookmark(int index) async {
    if (index >= 0 && index < _bookmarkedRecipes.length) {
      setState(() {
        _bookmarkedRecipes.removeAt(index);
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'bookmarkedRecipes', json.encode(_bookmarkedRecipes));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe dihapus dari bookmark')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error: Gagal untuk menghapus bookmark. Index out of range.')),
      );
    }
  }

  void _searchRecipes() async {
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Masukkan nama bahan terlebih dahulu')),
      );
      return;
    }
    try {
      final recipes = await _apiService.fetchRecipesByIngredients(_ingredients);
      setState(() {
        _recipes = recipes;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipes: $error')),
      );
    }
  }

  void _addIngredient(String ingredient) {
    if (ingredient.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bahan tidak boleh kosong')),
      );
    } else if (_ingredients.contains(ingredient)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bahan sudah tertulis')),
      );
    } else {
      setState(() {
        _ingredients.add(ingredient);
      });
      _controller.clear();
    }
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _showBookmarkedRecipes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bookmarked Recipes',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: _bookmarkedRecipes.isEmpty
                        ? Center(
                            child: Text(
                              'No bookmarked recipes',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _bookmarkedRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = _bookmarkedRecipes[index];
                              return Card(
                                elevation: 4.0,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                color: Color(0xFF333333),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      recipe['strMealThumb'] ??
                                          'https://via.placeholder.com/80', // Fallback image if null
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    recipe['strMeal'] ??
                                        '?', // Fallback text if null
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await _removeBookmark(index);
                                      modalSetState(() {});
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            RecipeDetailScreen(
                                          recipeId: recipe['idMeal'],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text('CariResep'),
        backgroundColor: Color(0xFF212121),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark, color: Colors.white),
            onPressed: _showBookmarkedRecipes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pencarian resep dari bahan',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Masukkan bahan (English)',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: Color(0xFF4CAF50)), // Hijau
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xFF4CAF50)), // Hijau saat fokus
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Color(0xFF4CAF50)), // Hijau saat tidak fokus
                      ),
                    ),
                    style: TextStyle(
                        color:
                            Colors.white), // Teks di dalam input berwarna putih
                    onSubmitted: (_) => _addIngredient(_controller.text),
                  ),
                ),
                IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () => _addIngredient(_controller.text)),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8.0,
              children: _ingredients
                  .map((ingredient) => Chip(
                        label: Text(ingredient,
                            style: TextStyle(color: Colors.white)),
                        backgroundColor: Color(0xFF444444),
                        shape: StadiumBorder(
                            side: BorderSide(color: Color(0xFF4CAF50))),
                        deleteIconColor: Color(0xFF4CAF50), // Hijau
                        onDeleted: () =>
                            _removeIngredient(_ingredients.indexOf(ingredient)),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _searchRecipes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50), // Hijau
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Center(
                  child: Text('Cari resep',
                      style: TextStyle(fontSize: 18, color: Colors.white))),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _recipes.isEmpty
                  ? Center(
                      child: Text(
                          'Tidak dapat menemukan resep. Coba gunakan bahan yang lain!',
                          style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: _recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = _recipes[index];
                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          color: Color(0xFF333333),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(10),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                recipe['strMealThumb'],
                                width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              recipe['strMeal'],
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.bookmark_add,
                                  color: Colors.yellow),
                              onPressed: () => _bookmarkRecipe(
                                  recipe), // Call the method to bookmark the recipe
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeDetailScreen(
                                    recipeId: recipe['idMeal'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
