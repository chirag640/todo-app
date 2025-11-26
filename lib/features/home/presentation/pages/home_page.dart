import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_button.dart';

/// Home page - My Tasks screen
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';

  // Mock data for tasks
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Design final mockups',
      'dueDate': 'Tomorrow',
      'priority': 'high',
      'isCompleted': false,
    },
    {
      'title': 'Develop login feature',
      'dueDate': 'Oct 25',
      'priority': 'medium',
      'isCompleted': true,
    },
    {
      'title': 'Submit weekly report',
      'dueDate': 'Friday',
      'priority': 'low',
      'isCompleted': false,
    },
    {
      'title': 'Fix API authentication bug',
      'dueDate': 'Today',
      'priority': 'high',
      'isCompleted': false,
    },
    {
      'title': 'Water the plants',
      'dueDate': 'No due date',
      'priority': 'none',
      'isCompleted': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index]['isCompleted'] = !_tasks[index]['isCompleted'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading:
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: CircleAvatar(
              radius: 13.sp,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.white,
                size: 5.w,
              ),
            ),
          ),
        
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Search and Filter Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.5.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Filter Buttons
                  FilterButton(
                    icon: Icons.tune_rounded,
                    isActive: _selectedFilter == 'filter',
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'filter';
                      });
                      // TODO: Show filter dialog
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Task List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: TaskCard(
                      title: task['title'],
                      dueDate: task['dueDate'],
                      priority: task['priority'],
                      isCompleted: task['isCompleted'],
                      onToggle: () => _toggleTaskComplete(index),
                      onTap: () {
                        // TODO: Navigate to task details
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 14.w,
        height: 14.w,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 12.sp,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () {
            // TODO: Add new task
          },
          icon: Icon(
            Icons.add_rounded,
            size: 8.w,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
