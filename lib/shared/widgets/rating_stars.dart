import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BridgoRatingStars extends StatelessWidget {
  final double rating;
  final int maxStars;
  final double size;
  final bool showRatingText;
  final int? reviewCount;

  const BridgoRatingStars({
    super.key,
    required this.rating,
    this.maxStars = 5,
    this.size = 16,
    this.showRatingText = true,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxStars, (index) {
            final starValue = index + 1;
            if (rating >= starValue) {
              return Icon(Icons.star_rounded, color: Colors.amber, size: size);
            } else if (rating >= starValue - 0.5) {
              return Icon(Icons.star_half_rounded, color: Colors.amber, size: size);
            } else {
              return Icon(Icons.star_outline_rounded, color: AppColors.textMuted, size: size);
            }
          }),
        ),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        if (reviewCount != null) ...[
          const SizedBox(width: 2),
          Text(
            '($reviewCount)',
            style: TextStyle(
              fontSize: size * 0.75,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
