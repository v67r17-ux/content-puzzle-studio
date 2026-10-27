import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/content_item.dart';
import '../models/puzzle.dart';

/// Local cross-platform starter storage. Replace with a repository backed by
/// SQLite/Drift or an API when you need sync, accounts, and larger datasets.
class LocalStore {
  static const _contentKey = 'content_items_v1';
  static const _puzzlesKey = 'puzzles_v1';

  Future<List<ContentItem>> loadContent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_contentKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ContentItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveContent(List<ContentItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_contentKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<Puzzle>> loadPuzzles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_puzzlesKey);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => Puzzle.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePuzzles(List<Puzzle> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_puzzlesKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }
}
