import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../data/review_storage.dart';
import '../models/recipe.dart';
import '../models/review.dart';
import '../utils/colors.dart';

class ReviewScreen extends StatefulWidget {
  final FoodItemData recipe;

  const ReviewScreen({super.key, required this.recipe});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  List<Review> _reviews = [];
  int _pendingRating = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadReviews() {
    setState(() {
      _reviews = ReviewStorage.getReviewsForRecipe(widget.recipe.title);
    });
  }

  Future<void> _submitReview() async {
    if (_pendingRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a star rating.',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.textDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    setState(() => _submitting = true);

    final review = Review(
      id: '${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      recipeTitle: widget.recipe.title,
      userId: user.id,
      userName: user.displayName,
      rating: _pendingRating,
      comment: _commentController.text.trim(),
      createdAt: DateTime.now(),
    );

    await ReviewStorage.addReview(review);
    _commentController.clear();
    setState(() {
      _pendingRating = 0;
      _submitting = false;
    });
    _loadReviews();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted!',
              style: GoogleFonts.poppins(fontSize: 13)),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays}d ago';
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final avgRating = ReviewStorage.getAverageRating(widget.recipe.title);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ratings & Reviews'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRatingSummary(avgRating),
          const SizedBox(height: 24),
          _buildWriteReview(),
          const SizedBox(height: 24),
          if (_reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    const Icon(Icons.rate_review_outlined,
                        size: 48, color: AppColors.textLight),
                    const SizedBox(height: 12),
                    Text(
                      'No reviews yet.\nBe the first to review!',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                          color: AppColors.textLight, height: 1.6),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._reviews.map((r) => _buildReviewCard(r)),
        ],
      ),
    );
  }

  Widget _buildRatingSummary(double avgRating) {
    final displayRating =
        avgRating == 0.0 ? widget.recipe.rating : avgRating;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                displayRating.toStringAsFixed(1),
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < displayRating.round()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentAmber,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_reviews.length} ${_reviews.length == 1 ? 'review' : 'reviews'}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textLight),
              ),
            ],
          ),
          const SizedBox(width: 20),
          const VerticalDivider(color: AppColors.chipBg, thickness: 1),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count =
                    _reviews.where((r) => r.rating == star).length;
                final fraction =
                    _reviews.isEmpty ? 0.0 : count / _reviews.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star',
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: AppColors.textLight)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star_rounded,
                          size: 11, color: AppColors.accentAmber),
                      const SizedBox(width: 6),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: fraction,
                          backgroundColor: AppColors.chipBg,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.accentAmber),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 20,
                        child: Text('$count',
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textLight)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Write a Review',
              style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _pendingRating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _pendingRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentAmber,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _commentController,
            maxLines: 3,
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textDark),
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textLight),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.chipBg),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.chipBg),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.all(14),
              filled: true,
              fillColor: AppColors.bgMuted,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('Submit Review',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.chipBg,
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMid),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textDark)),
                    Text(_timeAgo(review.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accentAmber,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMid,
                    height: 1.5)),
          ],
        ],
      ),
    );
  }
}
