import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Service to monitor and check internet connectivity
class ConnectivityService extends GetxService {
  static ConnectivityService get instance => Get.find<ConnectivityService>();

  final RxBool isConnected = true.obs;
  final RxBool isChecking = false.obs;

  Timer? _periodicCheck;

  @override
  void onInit() {
    super.onInit();
    checkConnection();
    // Periodic check every 30 seconds
    _periodicCheck = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkConnection(),
    );
  }

  @override
  void onClose() {
    _periodicCheck?.cancel();
    super.onClose();
  }

  /// Check if device has internet connectivity
  Future<bool> checkConnection() async {
    if (isChecking.value) return isConnected.value;

    isChecking.value = true;

    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        isConnected.value = true;
        debugPrint('✅ Internet connection available');
      } else {
        isConnected.value = false;
        debugPrint('❌ No internet connection');
      }
    } on SocketException catch (_) {
      isConnected.value = false;
      debugPrint('❌ No internet connection (SocketException)');
    } on TimeoutException catch (_) {
      isConnected.value = false;
      debugPrint('❌ No internet connection (Timeout)');
    } catch (e) {
      isConnected.value = false;
      debugPrint('❌ No internet connection: $e');
    }

    isChecking.value = false;
    return isConnected.value;
  }

  /// Force refresh connection status
  Future<bool> refreshConnection() async {
    return await checkConnection();
  }
}
