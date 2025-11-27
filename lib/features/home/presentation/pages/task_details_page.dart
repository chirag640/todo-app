import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'edit_task_page.dart';

class TaskDetailsPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailsPage({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsPage> createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task['isCompleted'] ?? false;
  }

  void _toggleCompletion() {
    setState(() {
      _isCompleted = !_isCompleted;
    });

    // Dispatch toggle event
    context.read<TaskBloc>().add(
          ToggleTaskCompletionEvent(widget.task['id'], _isCompleted),
        );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Task',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Dispatch delete event
              context.read<TaskBloc>().add(DeleteTaskEvent(widget.task['id']));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor() {
    switch (widget.task['priority']) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityText() {
    switch (widget.task['priority']) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'None';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            CustomScrollView(
              slivers: [
                // Custom App Bar with Hero Effect
                SliverAppBar(
                  expandedHeight: 15.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Container(
                    margin: EdgeInsets.only(left: 3.w, top: 0.5.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.white,
                        size: 5.w,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  flexibleSpace: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    child: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryDark,
                            ],
                          ),
                        ),
                        child: SafeArea(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (widget.task['category'] != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 2.5.w,
                                      vertical: 0.4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      widget.task['category']
                                          .toString()
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                        letterSpacing: 0.8,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                SizedBox(height: 0.8.h),
                                Text(
                                  widget.task['title'] ?? '',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Shadow separator
                SliverToBoxAdapter(
                  child: Container(
                    height: 2.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(6.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Card with Animation
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isCompleted
                                  ? [
                                      AppColors.completed.withOpacity(0.1),
                                      AppColors.completed.withOpacity(0.05),
                                    ]
                                  : [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isCompleted
                                  ? AppColors.completed
                                  : AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _toggleCompletion,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 11.w,
                                  height: 11.w,
                                  decoration: BoxDecoration(
                                    color: _isCompleted
                                        ? AppColors.completed
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isCompleted
                                          ? AppColors.completed
                                          : AppColors.primary,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: _isCompleted
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: AppColors.white,
                                          size: 6.w,
                                        )
                                      : null,
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _isCompleted
                                          ? 'Completed ✨'
                                          : 'Mark as Complete',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: _isCompleted
                                            ? AppColors.completed
                                            : AppColors.primary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      _isCompleted
                                          ? 'Great job! Task finished'
                                          : 'Tap to complete this task',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: AppColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 2.5.h),

                        // Info Cards Grid
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.calendar_today_rounded,
                                label: 'Due Date',
                                value: widget.task['dueDate'] ?? 'No date',
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: _buildInfoCard(
                                icon: Icons.flag_rounded,
                                label: 'Priority',
                                value: _getPriorityText(),
                                color: _getPriorityColor(),
                              ),
                            ),
                          ],
                        ),

                        // Description Section
                        if (widget.task['description'] != null &&
                            widget.task['description']
                                .toString()
                                .isNotEmpty) ...[
                          SizedBox(height: 2.5.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.5.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.description_rounded,
                                  color: AppColors.primary,
                                  size: 4.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Flexible(
                                child: Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.5.h),
                          Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight: 8.h,
                              maxHeight: 30.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Text(
                                widget.task['description'] ?? '',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Buttons
            Positioned(
              bottom: 2.5.h,
              left: 6.w,
              right: 6.w,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 5.5.h,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditTaskPage(
                                    task: widget.task,
                                  ),
                                ),
                              );
                              if (result != null && result == true) {
                                // Task was updated via BLoC, just go back
                                Navigator.pop(context, true);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 4.5.w,
                                    color: AppColors.textPrimary,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Edit Task',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      height: 5.5.h,
                      width: 5.5.h,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete_rounded,
                          color: AppColors.white,
                          size: 5.w,
                        ),
                        onPressed: _showDeleteConfirmation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 3.w,
        vertical: 1.8.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(1.8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 5.w,
            ),
          ),
          SizedBox(height: 1.2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 0.3.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
