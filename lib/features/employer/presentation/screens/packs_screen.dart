import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class HiringPack {
  final String id;
  final String title;
  final int hiresCount;
  final double price;
  final double perHirePrice;
  final String tag;
  final bool isPopular;
  final List<String> features;

  const HiringPack({
    required this.id,
    required this.title,
    required this.hiresCount,
    required this.price,
    required this.perHirePrice,
    required this.tag,
    this.isPopular = false,
    required this.features,
  });
}

class PacksScreen extends StatefulWidget {
  const PacksScreen({super.key});

  @override
  State<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends State<PacksScreen> {
  int _activeHiresRemaining = 8;
  final String _selectedPackId = 'pack-50';
  bool _isPurchasing = false;

  final List<HiringPack> _packs = const [
    HiringPack(
      id: 'pack-10',
      title: 'Starter Pack',
      hiresCount: 10,
      price: 899.0,
      perHirePrice: 89.9,
      tag: 'Save 10%',
      features: [
        '10 Verified Student Hires',
        'Valid for 6 months',
        'Direct in-app messaging',
        'Standard candidate support',
      ],
    ),
    HiringPack(
      id: 'pack-50',
      title: 'Growth Pack',
      hiresCount: 50,
      price: 3499.0,
      perHirePrice: 69.9,
      tag: 'Most Popular • Save 30%',
      isPopular: true,
      features: [
        '50 Verified Student Hires',
        'Valid for 12 months',
        'Priority Job Listing badge',
        'Instant Candidate SMS alerts',
        'Dedicated Account Manager',
      ],
    ),
    HiringPack(
      id: 'pack-100',
      title: 'Enterprise Pack',
      hiresCount: 100,
      price: 5999.0,
      perHirePrice: 59.9,
      tag: 'Best Value • Save 40%',
      features: [
        '100 Verified Student Hires',
        'No Expiry date',
        'Top of Search Feed boost',
        'Bulk onboarding assistance',
        'Custom hiring agreements & payroll API',
      ],
    ),
  ];

  Future<void> _handleBuyPack(HiringPack pack) async {
    setState(() => _isPurchasing = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _activeHiresRemaining += pack.hiresCount;
      _isPurchasing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully purchased ${pack.title}! +${pack.hiresCount} hires added.'),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hiring Packs & Credits'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Pack Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 34),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Hiring Credits',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$_activeHiresRemaining Hires Left',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Zero platform fees on your next hires',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Choose a Hiring Pack',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pre-purchase candidate hire slots at bulk discounts.',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // Packs list
            ..._packs.map((pack) {
              final isSelected = _selectedPackId == pack.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : (pack.isPopular ? AppColors.accent : AppColors.cardBorder),
                    width: isSelected || pack.isPopular ? 2 : 1,
                  ),
                  boxShadow: [
                    if (pack.isPopular)
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    if (pack.isPopular)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        child: const Center(
                          child: Text(
                            '★ MOST POPULAR VALUE ★',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pack.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${pack.hiresCount} candidate hires (₹${pack.perHirePrice.toStringAsFixed(0)} / hire)',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${pack.price.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: AppColors.cardBorder),
                          const SizedBox(height: 12),
                          ...pack.features.map(
                            (feat) => Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feat,
                                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pack.isPopular ? AppColors.accent : AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _isPurchasing ? null : () => _handleBuyPack(pack),
                              child: Text(
                                'Buy ${pack.title} (₹${pack.price.toStringAsFixed(0)})',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
