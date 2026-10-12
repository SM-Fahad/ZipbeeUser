import 'dart:async';
import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  IO.Socket? _socket;
  IO.Socket get socket => _socket!;
  bool isConnected = false;
  bool _isConnecting = false;

  final StreamController<MapEntry<String, dynamic>> _eventStreamController =
      StreamController<MapEntry<String, dynamic>>.broadcast();
  Stream<MapEntry<String, dynamic>> get incomingEvents =>
      _eventStreamController.stream;

  bool get hasSocket => _socket != null;

  factory SocketService() {
    return _instance;
  }

  final logger = Logger();

  SocketService._internal();

  final List<void Function()> _connectCallbacks = [];

  void onConnect(void Function() callback) {
    _connectCallbacks.add(callback);
    if (isConnected) {
      try {
        callback();
      } catch (e) {
        debugPrint('Error in onConnect callback: $e');
      }
    }
  }

  void offConnect(void Function() callback) {
    _connectCallbacks.remove(callback);
  }

  Future<void> connect(String token) async {
    if (isConnected && _socket != null && _socket!.connected) {
      debugPrint('✅ Socket already connected');
      return;
    }
    if (_isConnecting) {
      debugPrint('⏳ Socket connection attempt already in progress');
      return;
    }
    _isConnecting = true;
    logger.i('Connecting to socket: ${ApiEndPoint.socketUrl}');
    logger.i('Using token: $token');
    try {
      // Namespace is included in the URL for socket.io
      final socketUrl = '${ApiEndPoint.socketUrl}/user';

      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
              'authorization': 'Bearer $token',
            })
            .setQuery({'token': token})
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .enableReconnection()
            .enableForceNew()
            .build(),
      );

      _socket!.onConnect((_) {
        logger.i('✅ Socket connected to /user namespace');
        isConnected = true;
        _isConnecting = false;
        for (final cb in List.of(_connectCallbacks)) {
          try {
            cb();
          } catch (e) {
            debugPrint('Error in onConnect callback: $e');
          }
        }
      });

      _socket!.onDisconnect((_) {
        logger.i('❌ Socket disconnected');
        isConnected = false;
        _isConnecting = false;
      });

      _socket!.onConnectError((data) {
        logger.e('❌ Socket connection error: $data');
        isConnected = false;
        _isConnecting = false;
      });

      _socket!.onError((data) {
        logger.e('❌ Socket error: $data');
      });

      _socket!.onAny((event, data) {
        debugPrint('⚡ [SOCKET INCOMING] $event -> $data');
        try {
          _eventStreamController.add(MapEntry(event.toString(), data));
        } catch (_) {}
      });

      _socket!.connect();
      logger.i('Socket connection attempt started');
    } catch (e) {
      logger.e('❌ Error connecting to socket: $e');
      isConnected = false;
      _isConnecting = false;
    }
  }

  void emit(String event, [dynamic data]) {
    try {
      if (_socket != null) {
        _socket!.emit(event, data);
        debugPrint('📤 Socket emitted: $event with data: $data (connected: $isConnected)');
      } else {
        debugPrint('⚠️ Socket not initialized, cannot emit: $event');
      }
    } catch (e) {
      debugPrint('❌ Error emitting $event: $e');
    }
  }

  void on(String event, dynamic Function(dynamic) handler) {
    try {
      _socket?.on(event, handler);
      debugPrint('👂 Socket listening to: $event');
    } catch (e) {
      debugPrint('❌ Error registering listener for $event: $e');
    }
  }

  void off(String event, [dynamic Function(dynamic)? handler]) {
    try {
      _socket?.off(event, handler);
      debugPrint('🔇 Socket unregistered listener for: $event');
    } catch (e) {
      debugPrint('❌ Error unregistering listener for $event: $e');
    }
  }

  // Handle rider assigned event
  void handleRiderAssigned(dynamic data) {
    try {
      debugPrint(
        '🚴 Rider assigned - Order ID: ${data['orderId']}, Rider ID: ${data['riderId']}',
      );
    } catch (e) {
      debugPrint('❌ Error handling rider assigned: $e');
    }
  }

  void onAny(void Function(String event, dynamic data) handler) {
    _socket?.onAny((event, data) => handler(event, data));
  }

  // Disconnect from socket
  void disconnect() {
    if (isConnected && _socket != null) {
      _socket!.disconnect();
      isConnected = false;
      _isConnecting = false;
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
