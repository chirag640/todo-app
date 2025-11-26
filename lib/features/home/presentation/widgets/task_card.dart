import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String dueDate;
  final String priority;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.title,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.onToggle,
    required this.onTap,
  });

  Color _getPriorityColor() {
    switch (priority) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.sp),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Checkbox with larger tap area
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Container(
                  width: 5.w,
                  height: 5.w,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 3.w,
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(width: 2.w),

            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Due: $dueDate',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.normal,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Priority Indicator
            if (priority != 'none')
              Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
