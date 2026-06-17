import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  final notifications = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info(
      'NotificationsController.onInit(): loading notification history',
    );
    fetchNotifications();
  }

  void fetchNotifications() {
    AppLogger.debug(
      'NotificationsController.fetchNotifications(): loading mock notifications',
    );
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
    AppLogger.info('NotificationsController.markAsRead(): id=$id');
    final index = notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      notifications[index]['isRead'] = true;
      notifications.refresh();
    }
  }

  void clearAll() {
    AppLogger.warning(
      'NotificationsController.clearAll(): clearing notification list',
    );
    notifications.clear();
  }

  void toggleNotifications(bool value) {
    AppLogger.info(
      'NotificationsController.toggleNotifications(): value=$value',
    );
    _notificationService.toggleNotifications(value);
  }

  bool get isNotificationsEnabled => _notificationService.isEnabled.value;

  void testNotification() {
    AppLogger.info(
      'NotificationsController.testNotification(): sending test notification',
    );
    _notificationService.showTestNotification();
  }
}
