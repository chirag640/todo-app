import 'task_details_page.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/services/notification_service.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../data/models/task_model.dart';
import 'task_form_page.dart';

/// Home page - My Tasks screen
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedSortBy = 'createdAt';
  List<String> _selectedPriorities = [];
  String? _selectedStatus;
  String? _selectedDateFilter;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Load tasks when page is first opened
    context.read<TaskBloc>().add(const LoadTasksEvent());

    // Listen to search text changes
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Cancel previous timer if exists
    _searchDebounce?.cancel();

    // Create new timer with 400ms delay
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final query = _searchController.text;
      if (query.isEmpty) {
        context.read<TaskBloc>().add(const LoadTasksEvent());
      } else {
        context.read<TaskBloc>().add(SearchTasksEvent(query));
      }
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
        selectedStatus: _selectedStatus,
        selectedDateFilter: _selectedDateFilter,
        onApply: (sortBy, priorities, status, dateFilter) {
          setState(() {
            _selectedSortBy = sortBy;
            _selectedPriorities = priorities;
            _selectedStatus = status;
            _selectedDateFilter = dateFilter;
          });

          // Apply filter via BLoC
          context.read<TaskBloc>().add(FilterTasksEvent(
                priorities: priorities.contains('all') ? null : priorities,
                sortBy: sortBy,
                status: status,
                dateFilter: dateFilter,
              ));
        },
      ),
    );
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedPriorities.isNotEmpty) count++;
    if (_selectedStatus != null) count++;
    if (_selectedDateFilter != null) count++;
    if (_selectedSortBy != 'createdAt') count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedSortBy = 'createdAt';
      _selectedPriorities = [];
      _selectedStatus = null;
      _selectedDateFilter = null;
    });
    context.read<TaskBloc>().add(const LoadTasksEvent());
  }

  Future<void> _navigateToNewTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormPage(),
      ),
    );

    // Reload tasks after returning from new task page
    if (result != null && mounted) {
      context.read<TaskBloc>().add(const LoadTasksEvent());
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

  Future<void> _navigateToTaskDetails(TaskModel task) async {
    // Convert TaskModel to Map for compatibility with TaskDetailsPage
    final taskMap = _taskToMap(task);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: taskMap,
        ),
      ),
    );
    // Tasks will auto-refresh via BLoC when returning
  }

  Map<String, dynamic> _taskToMap(TaskModel task) {
    return {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'dueDate':
          task.dueDate != null ? _formatDate(task.dueDate!) : 'No due date',
      'dueDateRaw': task.dueDate, // Add raw DateTime for edit page
      'priority': task.priority.toLowerCase(),
      'category': task.category,
      'isCompleted': task.isCompleted,
    };
  }

  int _calculateActiveTasksCount(List<TaskModel> tasks) {
    return tasks.where((task) => task.status != 'Completed').length;
  }

  bool _isFilterActive(TaskState state) {
    if (state is TaskLoaded) {
      return state.isFiltered ||
          state.isSearching ||
          _selectedSortBy != 'priority' ||
          !_selectedPriorities.contains('all');
    }
    return false;
  }

  Widget _buildTaskList(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Create a new task to get started',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(const RefreshTasksEvent());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final taskMap = _taskToMap(task);

          return TaskCard(
            title: taskMap['title'],
            dueDate: taskMap['dueDate'],
            priority: taskMap['priority'],
            isCompleted: taskMap['isCompleted'],
            onToggle: () {
              if (task.id != null && task.id!.isNotEmpty) {
                context.read<TaskBloc>().add(
                      ToggleTaskCompletionEvent(task.id!, !task.isCompleted),
                    );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.white),
                        SizedBox(width: 2.w),
                        const Expanded(
                          child:
                              Text('Error: Cannot toggle task - ID is missing'),
                        ),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            onTap: () => _navigateToTaskDetails(task),
          );
        },
      ),
    );
  }

  Widget _buildHeader(TaskState state) {
    final activeCount =
        state is TaskLoaded ? _calculateActiveTasksCount(state.tasks) : 0;
    final isFilterActive = _isFilterActive(state);

    return Container(
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
                        '$activeCount active',
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
                        contentPadding: EdgeInsets.symmetric(vertical: 1.h),
                      ),
                      cursorColor: AppColors.white,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: isFilterActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: isFilterActive
                                ? AppColors.primary
                                : AppColors.white,
                            size: 5.w,
                          ),
                        ),
                        if (_getActiveFilterCount() > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 4.w,
                                minHeight: 4.w,
                              ),
                              child: Center(
                                child: Text(
                                  '${_getActiveFilterCount()}',
                                  style: TextStyle(
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          // Show snackbar for operation success
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Show snackbar for errors
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        child: GestureDetector(
          onTap: () {
            // Dismiss keyboard when tapping anywhere
            _searchFocusNode.unfocus();
          },
          child: SafeArea(
            child: BlocBuilder<TaskBloc, TaskState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Gradient Header with Rounded Bottom
                    _buildHeader(state),
                    SizedBox(height: 2.h),

                    // Task List or State-based UI
                    Expanded(
                      child: _buildContent(state),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Test Notification Button
          FloatingActionButton(
            heroTag: 'test_notification',
            onPressed: () async {
              try {
                await NotificationService.instance.showInstantNotification(
                  title: '🎉 Test Notification',
                  body: 'Your notification system is working perfectly!',
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Test notification sent!'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                debugPrint('Failed to send test notification: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Error: $e'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            backgroundColor: Colors.orange,
            child: const Icon(Icons.notifications_active),
          ),
          SizedBox(height: 2.h),
          // Add Task Button
          Container(
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
        ],
      ),
    );
  }

  Widget _buildContent(TaskState state) {
    if (state is TaskLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (state is TaskEmpty) {
      final hasSearch = _searchController.text.isNotEmpty;
      final hasFilters = _getActiveFilterCount() > 0;

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch || hasFilters
                  ? Icons.search_off_rounded
                  : Icons.inbox_rounded,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: 2.h),
            Text(
              state.message,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              hasSearch || hasFilters
                  ? 'Try adjusting your search or filters'
                  : 'Tap the + button to create your first task',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (hasSearch || hasFilters) ...[
              SizedBox(height: 3.h),
              ElevatedButton.icon(
                onPressed: _clearAllFilters,
                icon: Icon(Icons.clear_all_rounded, size: 5.w),
                label: Text('Clear All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (state is TaskError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: AppColors.error.withOpacity(0.5),
            ),
            SizedBox(height: 2.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                state.message,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TaskBloc>().add(const LoadTasksEvent());
              },
              icon: Icon(Icons.refresh_rounded),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 1.5.h,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (state is TaskLoaded) {
      return _buildTaskList(state.tasks);
    }

    if (state is TaskOperationSuccess) {
      return _buildTaskList(state.tasks);
    }

    // Initial or unknown state
    return Center(
      child: Text(
        'Welcome to My Tasks',
        style: TextStyle(
          fontSize: 16.sp,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
