import 'package:equatable/equatable.dart';

/// User model matching backend schema
class UserModel extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String? lastName;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    this.lastName,
    required this.roles,
    this.createdAt,
    this.updatedAt,
  });

  String get fullName => lastName != null && lastName!.isNotEmpty
      ? '$firstName $lastName'
      : firstName;

  bool get isAdmin => roles.contains('Admin');
  bool get isUser => roles.contains('User');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] != null && json['lastName'] != ''
            ? json['lastName'] as String
            : null,
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            ['User'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      throw Exception('Error parsing UserModel: $e\nJSON: $json');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      'roles': roles,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    List<String>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, firstName, lastName, roles, createdAt, updatedAt];
}
