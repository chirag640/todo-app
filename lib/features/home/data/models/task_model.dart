import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String? id;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final String? category;
  final DateTime? dueDate;
  final DateTime? startDate;
  final DateTime? completedAt;
  final List<String>? tags;
  final bool isArchived;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TaskModel({
    this.id,
    required this.title,
    this.description,
    this.status = 'Pending',
    this.priority = 'Medium',
    this.category,
    this.dueDate,
    this.startDate,
    this.completedAt,
    this.tags,
    this.isArchived = false,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  // Helper getter for frontend compatibility
  bool get isCompleted => status == 'Completed';

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      // Backend returns 'id', but also check '_id' for MongoDB compatibility
      id: (json['id'] ?? json['_id']) as String?,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'Pending',
      priority: json['priority'] as String? ?? 'Medium',
      category: json['category'] as String?,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String).toLocal()
          : null,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String).toLocal()
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      isArchived: json['isArchived'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Don't include _id in request body - it goes in the URL
      'title': title,
      if (description != null) 'description': description,
      'status': status,
      'priority': priority,
      if (category != null) 'category': category,
      if (dueDate != null) 'dueDate': dueDate!.toUtc().toIso8601String(),
      if (startDate != null) 'startDate': startDate!.toUtc().toIso8601String(),
      if (completedAt != null)
        'completedAt': completedAt!.toUtc().toIso8601String(),
      if (tags != null) 'tags': tags,
      // Don't send isArchived and isDeleted unless they're true (backend defaults to false)
      if (isArchived) 'isArchived': isArchived,
      if (isDeleted) 'isDeleted': isDeleted,
    };
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? category,
    DateTime? dueDate,
    DateTime? startDate,
    DateTime? completedAt,
    List<String>? tags,
    bool? isArchived,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      startDate: startDate ?? this.startDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      isArchived: isArchived ?? this.isArchived,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        category,
        dueDate,
        startDate,
        completedAt,
        tags,
        isArchived,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
