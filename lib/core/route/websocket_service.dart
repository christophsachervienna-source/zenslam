import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketService {
  IOWebSocketChannel? channel;
  Function(Map<String, dynamic>)? onMessageReceived;

  Future<void> connect(String url, String token) async {
    try {
      final bearerToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final headers = {'Authorization': bearerToken};

      if (kDebugMode) {
        debugPrint("🔌 Connecting to WebSocket...");
        debugPrint("🌐 URL: $url");
      }

      // Use WebSocket.connect to ensure headers are sent properly
      final webSocket = await WebSocket.connect(url, headers: headers);

      if (kDebugMode) {
        debugPrint("✅ WebSocket connected successfully!");
      }

      channel = IOWebSocketChannel(webSocket);

      channel!.stream.listen(
        (message) => _handleMessage(message),

        onDone: () {
          if (kDebugMode) debugPrint("❌ WebSocket connection closed.");
        },
        onError: (error) {
          if (kDebugMode) debugPrint("⚠️ WebSocket error: $error");
        },
      );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint("❌ WebSocket connection failed: $e");
        debugPrint("📍 Stack trace: $stackTrace");
      }
    }
  }

  void _handleMessage(String message) {
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic>) {
        if (kDebugMode) debugPrint("Received WebSocket message: $decoded");
        onMessageReceived?.call(decoded);
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Error decoding WebSocket message: $e");
    }
  }

  void sendMessage(String event, [Map<String, dynamic>? data]) {
    if (channel == null) {
      if (kDebugMode) debugPrint("WebSocket channel is not connected.");
      return;
    }

    final message = {"event": event, ...?data};
    final encoded = jsonEncode(message);
    channel!.sink.add(encoded);

    if (kDebugMode) debugPrint("Sent WebSocket message: $encoded");
  }

  void close() {
    channel?.sink.close();
    channel = null;
    if (kDebugMode) debugPrint("WebSocket closed.");
  }

  Stream get messages => channel?.stream ?? Stream.empty();
}
