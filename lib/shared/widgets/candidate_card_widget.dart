import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'rating_stars.dart';

class CandidateModel {
  final String id;
  final String name;
  final String title;
  final double rating;
  final int reviewsCount;
  final double distanceKm;
  final List<String> skills;
  final String availability;
  final String hourlyRate;
  final String experience;
  final String education;
  final String about;
  final String phone;
  final String email;
  final String status;

  const CandidateModel({
    required this.id,
    required this.name,
    required this.title,
    required this.rating,
    required this.reviewsCount,
    required this.distanceKm,
    required this.skills,
    required this.availability,
    required this.hourlyRate,
    required this.experience,
    required this.education,
    required this.about,
    required this.phone,
    required this.email,
    this.status = 'AVAILABLE',
  });
}

class CandidateCardWidget extends StatelessWidget {
  final CandidateModel candidate;
  final VoidCallback onTap;
  final VoidCallback? onHire;
  final VoidCallback? onChat;

  const CandidateCardWidget({
    super.key,
    required this.candidate,
    required this.onTap,
    this.onHire,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      candidate.name.isNotEmpty ? candidate.name[0] : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          candidate.title,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BridgoRatingStars(
                          rating: candidate.rating,
                          reviewCount: candidate.reviewsCount,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 2),
                        Text(
                          '${candidate.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Skills
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: candidate.skills.take(4).map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 12),
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 15, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        candidate.availability,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (onChat != null) ...[
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, color: AppColors.primary, size: 20),
                      onPressed: onChat,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Chat with candidate',
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (onHire != null)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: onHire,
                      child: const Text(
                        'Hire Candidate',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
