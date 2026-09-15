enum NotificationCategory {
  appointment,
  clinical,
  laboratory,
  billing,
  system;

  String get displayName {
    switch (this) {
      case NotificationCategory.appointment:
        return 'Appointment';
      case NotificationCategory.clinical:
        return 'Clinical';
      case NotificationCategory.laboratory:
        return 'Laboratory';
      case NotificationCategory.billing:
        return 'Billing';
      case NotificationCategory.system:
        return 'System Alert';
    }
  }
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationCategory category;
  final bool isRead;
  final String? deepLinkRoute;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.category,
    this.isRead = false,
    this.deepLinkRoute,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    NotificationCategory? category,
    bool? isRead,
    String? deepLinkRoute,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRead: isRead ?? this.isRead,
      deepLinkRoute: deepLinkRoute ?? this.deepLinkRoute,
    );
  }
}
