import 'package:zenslam/core/const/shared_pref_helper.dart';
import 'package:zenslam/core/route/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isThinking = false.obs;
  var isConnected = false.obs;

  RxBool isLoggedIn = false.obs;
  final WebSocketService _ws = WebSocketService();
  @override
  void onInit() {
    super.onInit();
    messages.clear();
    loadUserName();
    _connectWebSocket();
  }

  void loadUserName() async {
    isLoggedIn.value = (await SharedPrefHelper.getAccessToken() != null)
        ? true
        : false;
    debugPrint(isLoggedIn.value.toString());
  }

  Future<void> _connectWebSocket() async {
    const url = "wss://api.malesync.com/ws/";
    final token = await SharedPrefHelper.getAccessToken();
    debugPrint("WebSocket URL: $url");

    _ws.onMessageReceived = (data) {
      final type = data['type'];

      if (type == 'error') {
        _handleError(data);
      } else if (data.containsKey('answer') && data.containsKey('question')) {
        _handleSendResponse(data);
      }
    };

    try {
      await _ws.connect(url, token ?? "");
      isConnected.value = true;
    } catch (e) {
      debugPrint("Failed to connect WebSocket: $e");
      isConnected.value = false;
    }
  }

  /// Handle error from server
  void _handleError(Map<String, dynamic> data) {
    isThinking.value = false;
    final errorMsg = data['message'] ?? 'Something went wrong';
    debugPrint("Server error: $errorMsg");
    messages.add({
      "sender": "bot",
      "msg": "Sorry, something went wrong. Please try again.",
      "time": DateTime.now(),
    });
  }

  /// Handle real-time bot reply after sending question
  void _handleSendResponse(Map<String, dynamic> data) {
    isThinking.value = false;
    final answer = data['answer'] ?? 'No response';
    messages.add({
      "sender": "bot",
      "msg": answer,
      "time": DateTime.now(),
    });
  }

  /// Send new question to server
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    if (!isConnected.value) {
      debugPrint("WebSocket not connected, cannot send message");
      return;
    }

    // Show user's message immediately
    messages.add({
      "sender": "user",
      "msg": text,
      "time": DateTime.now(),
    });

    // Show AI Thinking placeholder
    isThinking.value = true;

    final payload = {"type": "sendMessage", "question": text};
    _ws.sendMessage("sendMessage", payload);
  }

  @override
  void onClose() {
    _ws.close();
    super.onClose();
  }
}
