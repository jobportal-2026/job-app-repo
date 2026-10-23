import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BridgoStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const BridgoStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;

    switch (status.toUpperCase()) {
      case 'HIRED':
      case 'ACCEPTED':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_outline;
        break;
      case 'APPLIED':
      case 'PENDING':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF1D4ED8);
        icon = Icons.access_time_rounded;
        break;
      case 'COMPLETED':
        bg = const Color(0xFFF3E8FF);
        fg = const Color(0xFF7E22CE);
        icon = Icons.verified_rounded;
        break;
      case 'REJECTED':
      case 'CANCELLED':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_outlined;
        break;
      case 'ACTIVE':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF047857);
        icon = Icons.radio_button_checked_rounded;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = AppColors.textSecondary;
        icon = Icons.info_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: fg),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
