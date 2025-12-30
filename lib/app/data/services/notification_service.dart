import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _storage = GetStorage();
  final _key = 'isNotificationsEnabled';

  final isEnabled = false.obs;

  Future<NotificationService> init() async {
    isEnabled.value = _storage.read(_key) ?? false;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );
    return this;
  }

  Future<bool> requestPermissions() async {
    var status = await Permission.notification.status;
    if (status.isDenied) {
      status = await Permission.notification.request();
    }

    if (status.isPermanentlyDenied) {
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
    _setEnable(granted);
    return granted;
  }

  void _setEnable(bool value) {
    isEnabled.value = value;
    _storage.write(_key, value);
  }

  Future<void> toggleNotifications(bool value) async {
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
    if (!isEnabled.value) return;

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
    await showNotification(
      id: 0,
      title: 'Success! 🎉',
      body: 'Notifications are now active and working.',
      payload: 'test_payload',
    );
  }
}
