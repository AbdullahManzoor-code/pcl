import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/app_logger.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _storage = GetStorage();
  final _key = 'isNotificationsEnabled';

  final isEnabled = false.obs;

  Future<NotificationService> init() async {
    AppLogger.info(
      'NotificationService.init(): initializing local notifications',
    );
    isEnabled.value = _storage.read(_key) ?? false;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        AppLogger.info(
          'NotificationService.init(): notification tapped payload=${details.payload}',
        );
      },
    );
    return this;
  }

  Future<bool> requestPermissions() async {
    AppLogger.info(
      'NotificationService.requestPermissions(): requesting notification permission',
    );
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
      AppLogger.warning(
        'NotificationService.requestPermissions(): permission permanently denied',
      );
      Get.snackbar(
        'Permissions',
        'Notifications are disabled. Please enable them in settings.',
        mainButton: TextButton(
          onPressed: () => openAppSettings(),
          child: const Text('Settings'),
        ),
      );
      return false;
    }

    final granted = status.isGranted;
    AppLogger.info(
      'NotificationService.requestPermissions(): granted=$granted',
    );
    _setEnable(granted);
    return granted;
  }

  void _setEnable(bool value) {
    AppLogger.debug('NotificationService._setEnable(): enabled=$value');
    isEnabled.value = value;
    _storage.write(_key, value);
  }

  Future<void> toggleNotifications(bool value) async {
    AppLogger.info('NotificationService.toggleNotifications(): value=$value');
    if (value) {
      final granted = await requestPermissions();
      if (!granted) return;
    }
    _setEnable(value);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!isEnabled.value) {
      AppLogger.warning(
        'NotificationService.showNotification(): skipped because notifications are disabled',
      );
      return;
    }

    AppLogger.debug(
      'NotificationService.showNotification(): id=$id, title=$title',
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'pcl_notifications',
          'Course Updates',
          channelDescription: 'Notifications for course progress and updates',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> showTestNotification() async {
    AppLogger.info(
      'NotificationService.showTestNotification(): sending test notification',
    );
    await showNotification(
      id: 0,
      title: 'Success! 🎉',
      body: 'Notifications are now active and working.',
      payload: 'test_payload',
    );
  }
}
