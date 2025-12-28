import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum TimeFilter { today, thisWeek, thisMonth }

class HistoryFilter extends StatelessWidget {
  final TimeFilter selectedFilter;
  final Function(TimeFilter) onFilterChanged;

  const HistoryFilter({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'Aujourd\'hui',
          isSelected: selectedFilter == TimeFilter.today,
          onTap: () => onFilterChanged(TimeFilter.today),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Cette semaine',
          isSelected: selectedFilter == TimeFilter.thisWeek,
          onTap: () => onFilterChanged(TimeFilter.thisWeek),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: 'Ce mois',
          isSelected: selectedFilter == TimeFilter.thisMonth,
          onTap: () => onFilterChanged(TimeFilter.thisMonth),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.gray500,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
