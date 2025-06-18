import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final List<String> imagePaths;
  final DateTime time;
  final String status;
  final String username; // Add username field
  final String? assignedTo;
  final String priority;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.username, // Add to constructor
    required this.location,
    List<String>? imagePaths,
    DateTime? time,
    this.status = 'Nou',
    this.assignedTo,
    this.priority = 'Medium',
  })  : imagePaths = imagePaths ?? [],
        time = time ?? DateTime.now();

  // Date formatting
  String get formattedDate => DateFormat('dd/MM/yyyy').format(time);
  String get formattedTime => DateFormat('HH:mm').format(time);
  String get formattedDateTime => DateFormat('dd/MM/yyyy HH:mm').format(time);
  String get formattedDateTimeLong => DateFormat('dd MMM yyyy, HH:mm').format(time);

  // Status colors
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'nou':
        return Colors.orange;
      case 'în progres':
        return Colors.blue;
      case 'rezolvat':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Priority colors
  Color get priorityColor {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    // Helper function to parse image paths from various formats
    List<String> parseImagePaths(dynamic paths) {
      if (paths == null) return [];
      if (paths is String) return paths.isNotEmpty ? [paths] : [];
      if (paths is List) {
        return paths
            .map((p) => p?.toString())
            .where((p) => p != null && p.isNotEmpty)
            .toList()
            .cast<String>();
      }
      return [];
    }

    // Helper function to parse date time safely
    DateTime parseDateTime(dynamic date) {
      try {
        if (date is String) {
          return DateTime.parse(date);
        }
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    return Report(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      imagePaths: parseImagePaths(json['image_urls'] ?? json['image_paths']), // Handle both fields
      time: parseDateTime(json['created_at']),
      status: json['status']?.toString() ?? 'Nou',
      assignedTo: json['assigned_to']?.toString(),
      priority: json['priority']?.toString() ?? 'Medium',
      username: json['username']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'location': location,
        'image_paths': imagePaths,
        'status': status,
        'assigned_to': assignedTo,
        'priority': priority,
        'created_at': time.toIso8601String(),
      };

  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? location,
    List<String>? imagePaths,
    String? status,
    String? assignedTo,
    String? priority,
    DateTime? time,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      imagePaths: imagePaths ?? this.imagePaths,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      time: time ?? this.time,
      username: username,
    );
  }
}