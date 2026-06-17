import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/app_logger.dart';

/// Service to monitor network connectivity
class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final isOnline = true.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info(
      'ConnectivityService.onInit(): starting connectivity monitoring',
    );
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    try {
      AppLogger.debug(
        'ConnectivityService._initConnectivity(): checking current network state',
      );
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e, stackTrace) {
      AppLogger.error(
        'ConnectivityService._initConnectivity(): failed to check connectivity',
        e,
        stackTrace,
      );
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = isOnline.value;
    isOnline.value = results.any((result) => result != ConnectivityResult.none);

    AppLogger.info(
      'ConnectivityService._updateConnectionStatus(): online=${isOnline.value}, transports=${results.length}',
    );

    if (wasOnline && !isOnline.value) {
      AppLogger.warning(
        'ConnectivityService._updateConnectionStatus(): device went offline',
      );
      Get.snackbar(
        'Offline',
        'You are currently offline. Some features may be limited.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        duration: const Duration(seconds: 3),
      );
    } else if (!wasOnline && isOnline.value) {
      AppLogger.info(
        'ConnectivityService._updateConnectionStatus(): connection restored',
      );
      Get.snackbar(
        'Online',
        'Connection restored!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        icon: const Icon(Icons.wifi, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    }
  }
}
