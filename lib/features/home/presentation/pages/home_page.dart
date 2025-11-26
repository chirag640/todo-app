import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../widgets/task_card.dart';
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
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping anywhere
          _searchFocusNode.unfocus();
        },
        child: SafeArea(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.profile);
                            },
                            child: Container(
                              width: 11.w,
                              height: 11.w,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.person_rounded,
                                color: AppColors.white,
                                size: 5.w,
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                'My Tasks',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: 0.3.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.5.w,
                                  vertical: 0.3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_tasks.where((t) => !t['isCompleted']).length} active',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 11.w), // Spacer for centering
                        ],
                      ),
                      SizedBox(height: 2.5.h),

                      // Enhanced Search Bar
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                // color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.search_rounded,
                                color: AppColors.white,
                                size: 5.w,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search your tasks...',
                                  hintStyle: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white.withOpacity(0.7),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  fillColor: AppColors.white.withOpacity(0.0),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 1.h),
                                ),
                                cursorColor: AppColors.white,
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFilterBottomSheet,
                              child: Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: (_selectedFilter != 'all' ||
                                          _selectedSortBy != 'priority' ||
                                          !_selectedPriorities.contains('all'))
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: (_selectedFilter != 'all' ||
                                          _selectedSortBy != 'priority' ||
                                          !_selectedPriorities.contains('all'))
                                      ? AppColors.primary
                                      : AppColors.white,
                                  size: 5.w,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              // Task List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return TaskCard(
                      title: task['title'],
                      dueDate: task['dueDate'],
                      priority: task['priority'],
                      isCompleted: task['isCompleted'],
                      onToggle: () => _toggleTaskComplete(index),
                      onTap: () => _navigateToTaskDetails(index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _navigateToNewTask,
            borderRadius: BorderRadius.circular(50),
            child: Center(
              child: Icon(
                Icons.add_rounded,
                size: 9.w,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
