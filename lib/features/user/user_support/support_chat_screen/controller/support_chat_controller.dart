import 'dart:convert';
import 'dart:io';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:ZipBee/features/user/home/controller/profile_controller.dart';
import 'package:ZipBee/features/user/user_support/support_chat_screen/model/support_chat_model.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ZipBee/features/user/user_support/support_chat_screen/socket_service/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class ChatController extends GetxController {
  var messages = <Message>[].obs;
  var supportId = ''.obs; // store fetched support (admin) id
  var supportUsername = ''.obs; // store fetched admin username
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final isUploading = false.obs;
  final HomeController ctrl = Get.put(HomeController());
  final UserProfileController profileCtrl = Get.put(UserProfileController());
  String get userName => profileCtrl.userName.value.split(',').length > 1
      ? profileCtrl.userName.value.split(',')[1].trim()
      : profileCtrl.userName.value;

  @override
  void onInit() {
    super.onInit();
    loadInitialMessages();
    // fetch support id first, then initialize socket
    fetchSupportId().then((_) => initSocket());
  }

  /// Fetch support (admin) id from API and store in `supportId`
  Future<void> fetchSupportId() async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken() ?? '';
      final headers = <String, String>{'accept': '*/*'};
      if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(
        Uri.parse(ApiEndPoint.supportChat),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final data = body['data'];

        if (data != null) {
          // API returns an object like: { id: 1, username: 'superadmin', ... }
          if (data is Map) {
            final id = data['id']?.toString();
            final username = data['username']?.toString();
            if (id != null && id.isNotEmpty) supportId.value = id;
            if (username != null && username.isNotEmpty)
              supportUsername.value = username;
          } else if (data is List && data.isNotEmpty) {
            final first = data[0];
            final id = (first['_id'] ?? first['id'])?.toString();
            final username = first['username']?.toString();
            if (id != null && id.isNotEmpty) supportId.value = id;
            if (username != null && username.isNotEmpty)
              supportUsername.value = username;
          }
        }
      } else {
        // ignore non-200 for now
      }
    } catch (e) {
      // ignore errors for now
    }
  }

  /// Initialize socket for support chat
  Future<void> initSocket() async {
    final token = await SharedPreferencesHelper.getAccessToken();
    final userId = await SharedPreferencesHelper.getOrExtractUserId();
    if (token == null) {
      debugPrint("Token missing, cannot init support socket");
      return;
    }

    await SuppertSocketService().loadToken();
    SuppertSocketService().connect(userId: userId);

    SuppertSocketService().on('receive_message', (data) {
      debugPrint('📩 Support chat received message: $data');
      final content = data is Map ? (data['content'] ?? '') : '';
      final sender = supportUsername.value.isNotEmpty
          ? supportUsername.value
          : 'Support';
      messages.add(
        Message(sender: sender, text: content.toString(), isUser: false),
      );
      _scrollToBottom();
    });
  }

  void loadInitialMessages() {
    messages.addAll([
      Message(
        sender: "Sandy",
        text: "${userName}! How may I help you today?",
        isUser: false,
      ),

      Message(
        sender: "Sandy",
        text:
            "You may want to ask:\n• How I speed up my parcel delivery?\n• What if I confirmed the wrong order?\n• How do I raise a return/refund request?\n• Other Frequently Asked Questions?",
        isUser: false,
      ),
    ]);
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // add locally
    messages.add(Message(sender: 'You', text: text, isUser: true));

    // emit to server using supportId as receiver
    final parsedReceiverId = int.tryParse(supportId.value);
    final payload = {
      'receiverId': parsedReceiverId,
      'content': text,
      'messageType': 'TEXT',
    };

    SuppertSocketService().emit('send_message', payload);

    // clear input and scroll
    textController.clear();
    _scrollToBottom();
  }

  /// Pick image from gallery and send to support
  Future<void> pickImageAndSend() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked == null) return;

      isUploading.value = true;
      final file = File(picked.path);
      final url = await _uploadFile(file);
      if (url == null) return;

      messages.add(Message(sender: 'You', text: url, isUser: true));

      final parsedReceiverId = int.tryParse(supportId.value);
      final payload = {
        'receiverId': parsedReceiverId,
        'content': url,
        'messageType': 'IMAGE',
        'fileName': path.basename(file.path),
      };

      SuppertSocketService().emit('send_message', payload);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Support image send error: $e');
    } finally {
      isUploading.value = false;
    }
  }

  /// Pick any file and send to support
  Future<void> pickFileAndSend() async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;

      final picked = result.files.first;
      if (picked.path == null) return;

      isUploading.value = true;
      final file = File(picked.path!);
      final url = await _uploadFile(file);
      if (url == null) return;

      messages.add(Message(sender: 'You', text: url, isUser: true));

      final parsedReceiverId = int.tryParse(supportId.value);
      final payload = {
        'receiverId': parsedReceiverId,
        'content': url,
        'messageType': 'FILE',
        'fileName': picked.name,
      };

      SuppertSocketService().emit('send_message', payload);
      _scrollToBottom();
    } catch (e) {
      debugPrint('Support file send error: $e');
    } finally {
      isUploading.value = false;
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}';
      final ref = FirebaseStorage.instance
          .ref()
          .child('support_chat')
          .child(fileName);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      debugPrint('Support upload error: $e');
      return null;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    SuppertSocketService().dispose();
    super.onClose();
  }
}
