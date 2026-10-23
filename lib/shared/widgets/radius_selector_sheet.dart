import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BridgoRadiusSelectorSheet extends StatelessWidget {
  final int selectedRadiusKm;
  final ValueChanged<int> onRadiusSelected;

  const BridgoRadiusSelectorSheet({
    super.key,
    required this.selectedRadiusKm,
    required this.onRadiusSelected,
  });

  static void show(
    BuildContext context, {
    required int currentRadiusKm,
    required ValueChanged<int> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => BridgoRadiusSelectorSheet(
        selectedRadiusKm: currentRadiusKm,
        onRadiusSelected: (km) {
          onSelected(km);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radii = [5, 10, 25, 50, 100];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Job Search Radius',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Only jobs within this distance from your current location will be shown.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: radii.map((km) {
                final isSelected = km == selectedRadiusKm;
                return ChoiceChip(
                  label: Text('Within $km km'),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  avatar: Icon(
                    Icons.near_me_rounded,
                    size: 16,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                  onSelected: (_) => onRadiusSelected(km),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
