import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/global_widegts/network_response.dart';
import 'package:zenslam/app/notification_flow/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  RxBool isLoading = false.obs;
  var errorMessage = ''.obs;
  RxBool isUnauthorized = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';
    isUnauthorized.value = false;
    final token = await SharedPrefHelper.getAccessToken();

    try {
      final response = await ApiService.get(
        endpoint: 'notification/get-my-notifications',
        token: token,
      );

      debugPrint('📦 Notification API Response: ${response.data}');

      if (response.statusCode == 401) {
        isUnauthorized.value = true;
        isLoading.value = false;
        return;
      }

      if (response.data['success'] == true) {
        final notificationResponse = NotificationResponse.fromJson(
          response.data,
        );
        notifications.assignAll(notificationResponse.data.data);
        debugPrint('✅ Notifications loaded: ${notifications.length}');
      } else {
        debugPrint('❌ API returned success: false');
        final message =
            response.data['message'] ?? 'Failed to load notifications';
        errorMessage.value = message;
        Get.snackbar('Error', message);
      }
    } catch (e, stackTrace) {
      debugPrint('💥 Exception: $e');
      debugPrint('📝 Stack trace: $stackTrace');
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications();
  }
}
