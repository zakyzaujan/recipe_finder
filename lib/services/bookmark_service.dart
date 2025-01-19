// bookmark_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {
  Future<void> addToBookmarks(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    if (!bookmarks.contains(recipeId)) {
      bookmarks.add(recipeId);
      await prefs.setStringList('bookmarks', bookmarks);
    }
  }

  Future<void> removeFromBookmarks(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> bookmarks = prefs.getStringList('bookmarks') ?? [];
    bookmarks.remove(recipeId);
    await prefs.setStringList('bookmarks', bookmarks);
  }

  Future<List<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('bookmarks') ?? [];
  }
}
