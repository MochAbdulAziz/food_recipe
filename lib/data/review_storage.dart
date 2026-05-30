import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/review.dart';

/// Hive-backed storage for recipe reviews.
/// Each box key is a recipeTitle; value is a JSON array of Review objects.
class ReviewStorage {
  static const _boxName = 'reviews_v1';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static List<Review> getReviewsForRecipe(String recipeTitle) {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(recipeTitle);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static Future<void> addReview(Review review) async {
    final box = Hive.box<String>(_boxName);
    final existing = getReviewsForRecipe(review.recipeTitle);
    // One review per user per recipe — replace if already exists
    existing.removeWhere((r) => r.userId == review.userId);
    existing.insert(0, review);
    await box.put(
      review.recipeTitle,
      jsonEncode(existing.map((r) => r.toJson()).toList()),
    );
  }

  static double getAverageRating(String recipeTitle) {
    final reviews = getReviewsForRecipe(recipeTitle);
    if (reviews.isEmpty) return 0.0;
    return reviews.map((r) => r.rating).reduce((a, b) => a + b) /
        reviews.length;
  }

  static int getReviewCount(String recipeTitle) =>
      getReviewsForRecipe(recipeTitle).length;
}
