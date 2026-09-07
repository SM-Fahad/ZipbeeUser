import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late IO.Socket socket;
  bool isConnected = false;

  factory SocketService() {
    return _instance;
  }

  final logger = Logger();

  SocketService._internal();

  Future<void> connect( String token) async {
    print('Connecting to socket: ${ApiEndPoint.socketUrl}');
    print('Using token: $token');
    try {
      // Namespace is included in the URL for socket.io
      final socketUrl = '${ApiEndPoint.socketUrl}/user';

      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setPath('/socket.io/')
            .setAuth({'token': token})
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(10)
            .enableForceNew()
            .build(),
      );

      socket.onConnect((_) {
        logger.i('✅ Socket connected');
        isConnected = true;
      });

      socket.onDisconnect((_) {
        logger.i('❌ Socket disconnected');
        isConnected = false;
      });

      socket.onConnectError((data) {
        logger.e('❌ Socket connection error: $data');
        isConnected = false;
      });

      socket.onError((data) {
        logger.e('❌ Socket error: $data');
      });

      socket.connect();
      logger.i('Socket connection attempt started');
    } catch (e) {
      logger.e('❌ Error connecting to socket: $e');
      isConnected = false;
    }
  }


  // Handle rider assigned event
  void handleRiderAssigned(dynamic data) {
    try {
      debugPrint(
        '🚴 Rider assigned - Order ID: ${data['orderId']}, Rider ID: ${data['riderId']}',
      );
      // You can emit events or update UI state here
      // For example, if you're using GetX:
      // Get.find<HomeController>().onRiderAssigned(data);
    } catch (e) {
      debugPrint('❌ Error handling rider assigned: $e');
    }
  }

  void onAny(void Function(String event, dynamic data) handler) {
    socket.onAny((event, data) => handler(event, data));
  }

  // Disconnect from socket
  void disconnect() {
    if (isConnected) {
      socket.disconnect();
      isConnected = false;
      debugPrint('🔌 Socket disconnected');
    }
  }

  // Reconnect to socket
  Future<void> reconnect(String token) async {
    disconnect();
    await Future.delayed(const Duration(seconds: 1));
    await connect(token);
  }
}
