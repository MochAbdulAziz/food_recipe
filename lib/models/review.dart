import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String recipeTitle;
  final String userId;
  final String userName;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.recipeTitle,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        recipeTitle: json['recipeTitle'] as String,
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeTitle': recipeTitle,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  @override
  List<Object> get props =>
      [id, recipeTitle, userId, userName, rating, comment, createdAt];
}
