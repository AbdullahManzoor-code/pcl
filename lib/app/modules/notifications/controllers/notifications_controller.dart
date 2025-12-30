import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final notifications = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  void fetchNotifications() {
    // Mock notification history
    notifications.assignAll([
      {
        'id': 1,
        'title': 'Welcome to PCL! 🎓',
        'body': 'Start your programming journey by exploring our top courses.',
        'time': '2 hours ago',
        'isRead': true,
      },
      {
        'id': 2,
        'title': 'New Python Module Available',
        'body': 'Module 10: Data Visualization is now live!',
        'time': '5 hours ago',
        'isRead': false,
      },
      {
        'id': 3,
        'title': 'Daily Streak Reminder 🔥',
        'body':
            'Don\'t lose your 15-day streak! Spend 10 minutes learning today.',
        'time': '1 day ago',
        'isRead': true,
      },
    ]);
  }

  void markAsRead(int id) {
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
    }
  }

  void clearAll() {
    notifications.clear();
  }

  void toggleNotifications(bool value) {
    _notificationService.toggleNotifications(value);
  }

  bool get isNotificationsEnabled => _notificationService.isEnabled.value;

  void testNotification() {
    _notificationService.showTestNotification();
  }
}
