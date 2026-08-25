import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// شريط التنقل السفلي الزجاجي المشترك في واجهات شمسنا.
class ShamsunaBottomBar extends StatelessWidget {
  const ShamsunaBottomBar({
    required this.currentIndex,
    required this.onCreateReport,
    required this.onMyReports,
    required this.onHome,
    required this.onCompare,
    required this.onSuggestDevice,
    super.key,
  });

  final int currentIndex;
  final VoidCallback onCreateReport;
  final VoidCallback onMyReports;
  final VoidCallback onHome;
  final VoidCallback onCompare;
  final VoidCallback onSuggestDevice;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.panelNavy.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                _BarItem(
                  icon: Icons.add_chart_rounded,
                  label: 'إنشاء تقرير',
                  selected: currentIndex == 0,
                  onTap: onCreateReport,
                ),
                _BarItem(
                  icon: Icons.folder_copy_outlined,
                  label: 'تقاريري',
                  selected: currentIndex == 1,
                  onTap: onMyReports,
                ),
                _BarItem(
                  icon: Icons.home_rounded,
                  label: 'الرئيسية',
                  selected: currentIndex == 2,
                  emphasized: true,
                  onTap: onHome,
                ),
                _BarItem(
                  icon: Icons.compare_arrows_rounded,
                  label: 'مقارنة',
                  selected: currentIndex == 3,
                  onTap: onCompare,
                ),
                _BarItem(
                  icon: Icons.devices_other_rounded,
                  label: 'إضافة جهاز',
                  selected: currentIndex == 4,
                  onTap: onSuggestDevice,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(23),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: emphasized
              ? const EdgeInsets.symmetric(horizontal: 2)
              : EdgeInsets.zero,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.panelNavy.withValues(alpha: 0.94)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(emphasized ? 25 : 20),
            border: selected
                ? Border.all(color: AppColors.solarBlue.withValues(alpha: 0.72))
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.solarBlue.withValues(alpha: 0.24),
                      blurRadius: emphasized ? 16 : 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: emphasized ? 29 : 23,
                color: selected ? AppColors.solarBlue : AppColors.textLight,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.solarBlue : AppColors.textLight,
                  fontSize: emphasized ? 11.5 : 10.5,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
