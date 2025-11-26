import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_button.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'new_task_page.dart';
import 'task_details_page.dart';

/// Home page - My Tasks screen
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedFilter = 'all';
  String _selectedSortBy = 'priority';
  List<String> _selectedPriorities = ['all'];

  // Mock data for tasks
  final List<Map<String, dynamic>> _tasks = [
    {
      'title': 'Design final mockups',
      'dueDate': 'Tomorrow',
      'priority': 'high',
      'isCompleted': false,
      'description':
          'Create high-fidelity mockups for the mobile app including all main screens and user flows. Include dark mode variations.',
      'category': 'Project Alpha',
    },
    {
      'title': 'Develop login feature',
      'dueDate': 'Oct 25',
      'priority': 'medium',
      'isCompleted': true,
      'description':
          'Implement user authentication with email and social login options. Include forgot password functionality.',
    },
    {
      'title': 'Submit weekly report',
      'dueDate': 'Friday',
      'priority': 'low',
      'isCompleted': false,
      'description':
          'Prepare and submit the weekly progress report to the management team.',
    },
    {
      'title': 'Fix API authentication bug',
      'dueDate': 'Today',
      'priority': 'high',
      'isCompleted': false,
      'description':
          'Debug and fix the token refresh issue that causes users to be logged out unexpectedly.',
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
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleTaskComplete(int index) {
    setState(() {
      _tasks[index]['isCompleted'] = !_tasks[index]['isCompleted'];
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedSortBy: _selectedSortBy,
        selectedPriorities: _selectedPriorities,
        onApply: (sortBy, priorities) {
          setState(() {
            _selectedSortBy = sortBy;
            _selectedPriorities = priorities;
          });
        },
      ),
    );
  }

  Future<void> _navigateToNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewTaskPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _tasks.insert(0, {
          'title': result['title'],
          'dueDate': result['dueDate'] != null
              ? _formatDate(result['dueDate'])
              : 'No due date',
          'priority': result['priority'],
          'isCompleted': false,
        });
      });
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == DateTime(now.year, now.month, now.day)) {
      return 'Today';
    } else if (dateOnly == tomorrow) {
      return 'Tomorrow';
    } else {
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
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  Future<void> _navigateToTaskDetails(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: _tasks[index],
          onUpdate: (updatedTask) {
            setState(() {
              _tasks[index] = updatedTask;
            });
          },
          onDelete: () {
            setState(() {
              _tasks.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 8.h,
        title: Text(
          'My Tasks',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        leading: Padding(
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
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping anywhere
          _searchFocusNode.unfocus();
        },
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 1.h),

              // Search and Filter Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: SizedBox(
                        height: 6.h,
                        // decoration: BoxDecoration(
                        //   color: AppColors.white,
                        //   borderRadius: BorderRadius.circular(12),
                        //   boxShadow: [
                        //     BoxShadow(
                        //       color: AppColors.shadow,
                        //       blurRadius: 8,
                        //       offset: const Offset(0, 2),
                        //     ),
                        //   ],
                        // ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
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
                    ),
                    SizedBox(width: 3.w),

                    // Filter Buttons
                    FilterButton(
                      icon: Icons.tune_rounded,
                      isActive: _selectedFilter == 'filter',
                      onTap: _showFilterBottomSheet,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 1.h),

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
                        onTap: () => _navigateToTaskDetails(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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
          onPressed: _navigateToNewTask,
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
