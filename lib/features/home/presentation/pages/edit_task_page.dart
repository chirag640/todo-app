import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../../data/models/task_model.dart';

class EditTaskPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const EditTaskPage({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  String _selectedPriority = 'medium';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    // Pre-populate fields with existing task data
    _titleController.text = widget.task['title'] ?? '';
    _descriptionController.text = widget.task['description'] ?? '';
    _categoryController.text = widget.task['category'] ?? '';
    _selectedPriority = widget.task['priority'] ?? 'medium';
    if (widget.task['dueDate'] != null &&
        widget.task['dueDate'] != 'No due date') {
      try {
        _selectedDate = DateTime.parse(widget.task['dueDate']);
      } catch (e) {
        _selectedDate = null;
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Capitalize first letter of priority
    final priority =
        _selectedPriority[0].toUpperCase() + _selectedPriority.substring(1);

    // Create updated task model
    final updatedTask = TaskModel(
      id: widget.task['id'],
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      priority: priority,
      category: _categoryController.text.trim().isNotEmpty
          ? _categoryController.text.trim()
          : null,
      dueDate: _selectedDate,
      status: widget.task['isCompleted'] ? 'Completed' : 'Pending',
    );

    // Dispatch update event
    context
        .read<TaskBloc>()
        .add(UpdateTaskEvent(widget.task['id'], updatedTask));
    Navigator.pop(context, true);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header with Rounded Bottom
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 3.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.white,
                          size: 6.w,
                        ),
                      ),
                    ),
                    Text(
                      'Edit Task',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    GestureDetector(
                      onTap: _saveTask,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.white,
                          size: 6.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    _buildSectionTitle('Task Title'),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Buy groceries',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.8.h,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.5.h),

                    // Description Section
                    _buildSectionTitle('Description'),
                    SizedBox(height: 1.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Milk, eggs, bread...',
                          hintStyle: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 13.sp,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.8.h,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 2.5.h),

                    // Priority Section
                    _buildSectionTitle('Priority'),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        _buildPriorityButton('Low', 'low'),
                        SizedBox(width: 3.w),
                        _buildPriorityButton('Medium', 'medium'),
                        SizedBox(width: 3.w),
                        _buildPriorityButton('High', 'high'),
                      ],
                    ),

                    SizedBox(height: 2.5.h),

                    // Due Date Section
                    _buildSectionTitle('Due Date'),
                    SizedBox(height: 1.h),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? _formatDate(_selectedDate!)
                                    : 'Select a date',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: _selectedDate != null
                                      ? AppColors.textPrimary
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today_rounded,
                              color: AppColors.textSecondary,
                              size: 5.w,
                            ),
                          ],
                        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPriorityButton(String label, String value) {
    final isSelected = _selectedPriority == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPriority = value;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1.2.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.background,
            borderRadius: BorderRadius.circular(8.sp),
            border: isSelected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
