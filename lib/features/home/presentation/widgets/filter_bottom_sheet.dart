import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedSortBy;
  final List<String> selectedPriorities;
  final Function(String sortBy, List<String> priorities) onApply;

  const FilterBottomSheet({
    super.key,
    required this.selectedSortBy,
    required this.selectedPriorities,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _selectedSortBy;
  late List<String> _selectedPriorities;

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.selectedSortBy;
    _selectedPriorities = List.from(widget.selectedPriorities);
  }

  void _togglePriority(String priority) {
    setState(() {
      if (priority == 'all') {
        _selectedPriorities.clear();
        _selectedPriorities.add('all');
      } else {
        _selectedPriorities.remove('all');
        if (_selectedPriorities.contains(priority)) {
          _selectedPriorities.remove(priority);
          if (_selectedPriorities.isEmpty) {
            _selectedPriorities.add('all');
          }
        } else {
          _selectedPriorities.add(priority);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.5.h),
              width: 12.w,
              height: 0.6.h,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedSortBy = 'priority';
                        _selectedPriorities = ['all'];
                      });
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.8.h,
                      ),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sort By Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                children: [
                  _buildSortTab('Priority', 'priority'),
                  SizedBox(width: 3.w),
                  _buildSortTab('Due Date', 'dueDate'),
                  SizedBox(width: 3.w),
                  _buildSortTab('Created', 'created'),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Priority Filters
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Column(
                children: [
                  _buildPriorityOption('All', 'all', null),
                  SizedBox(height: 1.h),
                  _buildPriorityOption('High', 'high', AppColors.priorityHigh),
                  SizedBox(height: 1.h),
                  _buildPriorityOption(
                      'Medium', 'medium', AppColors.priorityMedium),
                  SizedBox(height: 1.h),
                  _buildPriorityOption('Low', 'low', AppColors.priorityLow),
                ],
              ),
            ),

            // SizedBox(height: 2.h),

            // Apply Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              child: SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_selectedSortBy, _selectedPriorities);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortTab(String label, String value) {
    final isSelected = _selectedSortBy == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedSortBy = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary,
                    width: 1.5,
                  )
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityOption(String label, String value, Color? dotColor) {
    final isSelected = _selectedPriorities.contains(value);
    return GestureDetector(
      onTap: () => _togglePriority(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12.sp),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : Border.all(color: AppColors.background, width: 2),
        ),
        child: Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 4.w),
            ],
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check_rounded,
                      color: AppColors.white,
                      size: 4.w,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
