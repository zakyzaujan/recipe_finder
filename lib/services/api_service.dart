import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Fungsi untuk mengambil resep berdasarkan bahan
  Future<List<dynamic>> fetchRecipesByIngredients(
      List<String> ingredients) async {
    final String ingredientsQuery = ingredients.join(',');
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/filter.php?i=$ingredientsQuery'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['meals'] ?? [];
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  // Fungsi untuk mengambil detail resep berdasarkan ID
  Future<Map<String, dynamic>> fetchRecipeDetails(String recipeId) async {
    final response = await http.get(Uri.parse(
        'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$recipeId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['meals'][0] ?? {};
    } else {
      throw Exception('Failed to load recipe details');
    }
  }
}
