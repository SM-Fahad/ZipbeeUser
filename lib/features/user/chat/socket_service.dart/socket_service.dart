import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';

class UserSocketService {
  // Singleton
  static final UserSocketService _instance = UserSocketService._internal();
  factory UserSocketService() => _instance;
  UserSocketService._internal();

  IO.Socket? socket;
  var token = ''.obs;

  /// Load token from local storage
  Future<void> loadToken() async {
    String accessToken = await SharedPreferencesHelper.getAccessToken() ?? '';
    token.value = accessToken; // ❗ only token, no Bearer
    if (kDebugMode) {
      debugPrint("📌 Socket Token Loaded: ${token.value}");
    }
  }

  final String baseUrl = '${ApiEndPoint.socketUrl}/api/v1/messages';

  /// CONNECT SOCKET
  void connect({required String? userId}) {
    if (token.value.isEmpty) {
      debugPrint("⚠️ Token not loaded yet.");
      return;
    }

    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'forceNew': true,
      // 'extraHeaders': {'Cookie': token.value},
      'auth': {'token': token.value}, //setAuth({'token': token})
      'reconnection': true,
      'reconnectionDelayMax': 5000,
      'pingInterval': 25000,
      'pingTimeout': 60000,
    });

    socket?.connect();

    // ✅ Connected
    socket?.onConnect((_) {
      debugPrint('✅ User socket connected');
      if (userId != null) {
        emit('register', {'userId': userId, 'role': 'user'});
      }
    });

    // ❌ Disconnected
    socket?.onDisconnect((_) => debugPrint('❌ Socket disconnected'));

    // ⚠ Errors
    socket?.onConnectError((e) => debugPrint('⚠️ Socket connect error: $e'));
    socket?.onError((e) => debugPrint('⚠️ Socket error: $e'));

    // 🔁 Reconnect
    socket?.onReconnectAttempt(
      (attempt) => debugPrint('🔄 Reconnect attempt #$attempt'),
    );
    socket?.onReconnect((_) => debugPrint('🔁 Socket reconnected'));
  }

  /// GENERIC EMIT
  void emit(String event, dynamic data, {Function(dynamic)? ack}) {
    if (ack != null) {
      socket?.emitWithAck(event, data, ack: ack);
      debugPrint('📤 Event "$event" sent with ack: $data');
    } else {
      socket?.emit(event, data);
      debugPrint('📤 Event "$event" sent: $data');
    }
  }

  /// GENERIC LISTENER
  void on(String event, Function(dynamic) callback) {
    socket?.on(event, (data) {
      debugPrint('📩 Event "$event" received: $data');
      callback(data);
    });
  }

  /// Remove listener
  void off(String event) {
    socket?.off(event);
    debugPrint('🔇 Listener "$event" removed');
  }

  /// Mark conversation as read
  void markAsRead(String conversationId) {
    if (conversationId.isEmpty) return;
    debugPrint('📖 User emitting mark_as_read for conversation: $conversationId');
    emit('mark_as_read', {'conversationId': conversationId}, ack: (response) {
      debugPrint('✅ User mark_as_read ack: $response');
    });
  }

  /// DISCONNECT SOCKET
  void dispose() {
    socket?.dispose();
    socket = null;
    debugPrint('🔌 Socket disposed');
  }
}
