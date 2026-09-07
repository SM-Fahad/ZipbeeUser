import 'dart:convert';
import 'dart:io';

import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/controllers/app_controller.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // ================= OBSERVABLES =================
  var userModel = UserModel(
    username: '',
    email: '',
    phone: '',
    userProfile: userProfileModel(firstName: '', lastName: '', dateOfBirth: ''),
    image: '',
  ).obs;
  //var isLoading = false.obs;
  var errorMessage = ''.obs;

  var firstName = ''.obs;
  var lastName = ''.obs;
  var dob = ''.obs;

  var profileItem = <ProfileModel>[].obs;
  var editingIndex = (-1).obs; // Which field is being edited

  // ================= IMAGE PICKING =================
  Rx<File?> profileImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  // ================= TEXT CONTROLLERS =================
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  int? userId; // store fetched userId

  // ================= FETCH USER PROFILE =================
  Future<void> fetchUserProfile() async {
    debugPrint(' Fetching user profile...');
    final token = await SharedPreferencesHelper.getAccessToken();

    if (token == null || token.isEmpty) {
      errorMessage('No access token found');
      debugPrint(' No access token found');
      return;
    }

    //isLoading(true);
    errorMessage('');

    final url = ApiEndPoint.profile; // /users/me
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      debugPrint('📥 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200) {
        final parsedResponse = json.decode(response.body);
        final data = parsedResponse['data'];
        if (data != null) {
          debugPrint('profile loaded: $data');
          debugPrint('eije profile : ${data['profile']}');
          userModel.value = UserModel.fromJsonData(data);
          userId = data['id']; // store ID in memory
          debugPrint('✅ User profile loaded: ${userModel.value.toJson()}');

          usernameController.text = userModel.value.username;
          emailController.text = userModel.value.email;
          phoneController.text = userModel.value.phone;
          firstNameController.text =
              userModel.value.userProfile?.firstName ?? '';
          lastNameController.text = userModel.value.userProfile?.lastName ?? '';
          dobController.text = formatIsoToDmy(userModel.value.userProfile?.dateOfBirth);

          updateProfileItems();
        }
      } else if (response.statusCode == 401) {
        errorMessage('Session expired. Please login again.');
        debugPrint('⚠️ Token expired');
        Get.offAllNamed('/login');
      } else {
        errorMessage('Failed to load profile: ${response.statusCode}');
        debugPrint('❌ Failed to load profile: ${response.statusCode}');
      }
    } catch (error) {
      errorMessage('Error fetching profile: $error');
      debugPrint('❌ Exception fetching profile: $error');
    } finally {
      //isLoading(false);
      debugPrint('⬅️ Finished fetching profile');
    }
  }

  // ================= UPDATE PROFILE LIST =================
  void updateProfileItems() {
    profileItem.clear();
    profileItem.add(
      ProfileModel(title: 'Username', subtitle: userModel.value.username),
    );
    profileItem.add(
      ProfileModel(title: 'Email', subtitle: userModel.value.email),
    );
    profileItem.add(
      ProfileModel(title: 'Phone', subtitle: userModel.value.phone),
    );
    debugPrint(
      '📄 Updated profile items: ${profileItem.map((e) => e.toJson())}',
    );
  }

  // ================= IMAGE METHODS =================
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        profileImage.value = File(file.path);
        debugPrint("Picked image: ${file.path}");
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<String?> uploadImage(File file) async {
    try {
      final token = await SharedPreferencesHelper.getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndPoint.upload),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      request.files.add(await http.MultipartFile.fromPath('images', file.path));

      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(body);
        return json['data']?[0];
      }
    } catch (e) {
      debugPrint("Error uploading image: $e");
    }
    return null;
  }

  Future<void> saveProfileImage() async {
    if (profileImage.value == null) return;

    final imageUrl = await uploadImage(profileImage.value!);
    if (imageUrl != null) {
      await updateUserProfile(image: imageUrl);
      profileImage.value = null; // Reset after success
    } else {
      Get.snackbar('Error', 'Failed to upload image');
    }
  }

  // ================= EDITING =================
  void startEditing(int index) {
    editingIndex.value = index;
    debugPrint('✏️ Start editing index: $index');
  }

  // ================= DATE HELPERS =================
  String formatIsoToDmy(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '';

    // Check if already in DD-MM-YYYY or DD/MM/YYYY format
    final dmyRegex = RegExp(r'^\d{1,2}[-/]\d{1,2}[-/]\d{4}$');
    if (dmyRegex.hasMatch(isoDate)) return isoDate;

    // Try parsing standard formats
    final parsed = DateTime.tryParse(isoDate);
    if (parsed != null) {
      return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}";
    }

    // Regex fallback for YYYY-MM-DD
    final isoRegex = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');
    final match = isoRegex.firstMatch(isoDate);
    if (match != null) {
      final year = match.group(1);
      final month = match.group(2)?.padLeft(2, '0');
      final day = match.group(3)?.padLeft(2, '0');
      return "$day-$month-$year";
    }

    return isoDate;
  }

  String? _tryFormatToIsoDate(String input) {
    input = input.trim();
    if (input.isEmpty) return null;

    // Try standard parser first
    final parsed = DateTime.tryParse(input);
    if (parsed != null) {
      return "${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}";
    }

    // Match DD-MM-YYYY or DD/MM/YYYY
    final dmyRegex = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$');
    final dmyMatch = dmyRegex.firstMatch(input);
    if (dmyMatch != null) {
      final day = int.tryParse(dmyMatch.group(1) ?? '');
      final month = int.tryParse(dmyMatch.group(2) ?? '');
      final year = int.tryParse(dmyMatch.group(3) ?? '');
      if (day != null && month != null && year != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          try {
            final date = DateTime(year, month, day);
            if (date.year == year && date.month == month && date.day == day) {
              return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            }
          } catch (_) {}
        }
      }
    }

    // Match YYYY/MM/DD
    final isoRegex = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})$');
    final isoMatch = isoRegex.firstMatch(input);
    if (isoMatch != null) {
      final year = int.tryParse(isoMatch.group(1) ?? '');
      final month = int.tryParse(isoMatch.group(2) ?? '');
      final day = int.tryParse(isoMatch.group(3) ?? '');
      if (year != null && month != null && day != null) {
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
          try {
            final date = DateTime(year, month, day);
            if (date.year == year && date.month == month && date.day == day) {
              return "${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}";
            }
          } catch (_) {}
        }
      }
    }

    return null;
  }

  void cancelEditing() {
    usernameController.text = userModel.value.username;
    emailController.text = userModel.value.email;
    phoneController.text = userModel.value.phone;
    firstNameController.text = userModel.value.userProfile?.firstName ?? '';
    lastNameController.text = userModel.value.userProfile?.lastName ?? '';
    dobController.text = formatIsoToDmy(userModel.value.userProfile?.dateOfBirth);
    editingIndex.value = -1;
    debugPrint('❌ Editing canceled');
  }

  // ================= UPDATE PROFILE API =================
  Future<void> updateUserProfile({
    String? username,
    String? email,
    String? phone,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? image,
  }) async {
    if (userId == null) {
      EasyLoading.showError('User ID not found');
      return;
    }

    final token = await SharedPreferencesHelper.getAccessToken();
    if (token == null || token.isEmpty) {
      EasyLoading.showError('No access token found');
      return;
    }

    final bodyData = <String, dynamic>{};
    if (username != null) bodyData['username'] = username;
    if (email != null) bodyData['email'] = email;
    if (phone != null) bodyData['phone'] = phone;
    if (firstName != null) bodyData['firstName'] = firstName;
    if (lastName != null) bodyData['lastName'] = lastName;
    if (dateOfBirth != null) {
      final formattedDob = _tryFormatToIsoDate(dateOfBirth);
      if (formattedDob == null) {
        EasyLoading.showError('Invalid date. Use DD-MM-YYYY or YYYY-MM-DD');
        return;
      }
      bodyData['dob'] = formattedDob;
    }
    if (image != null) bodyData['image'] = image;

    if (bodyData.isEmpty) return;

    EasyLoading.show(status: 'Updating profile...');
    errorMessage('');

    final url = ApiEndPoint.userProfile.replaceAll('{id}', userId.toString());
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    debugPrint('📡 PATCH $url');
    debugPrint('📝 Body: $bodyData');

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(bodyData),
      );
      debugPrint('📥 Response: ${response.statusCode} | ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final parsedResponse = json.decode(response.body);
        final data = parsedResponse['data'];
        if (data != null) {
          userModel.value = UserModel.fromJsonData(data);
          dobController.text = formatIsoToDmy(userModel.value.userProfile?.dateOfBirth);
        }
        updateProfileItems();
        editingIndex.value = -1;
        debugPrint('✅ Profile updated successfully');
        EasyLoading.showSuccess('Profile updated successfully');

        // 🔄 Trigger app rebuild to refresh data on all screens
        try {
          final appController = Get.find<AppController>();
          appController.rebuildApp();
          debugPrint('🔄 App rebuild triggered from profile controller');
        } catch (e) {
          debugPrint('⚠️ AppController not found: $e');
        }
      } else if (response.statusCode == 401) {
        EasyLoading.showError('Session expired. Please login again.');
        Get.offAllNamed('/login');
      } else {
        String errorMsg = 'Failed to update profile: ${response.statusCode}';
        try {
          final body = json.decode(response.body);
          final msg = body['message'];
          if (msg is List) {
            errorMsg = msg.join(', ');
          } else if (msg is String) {
            errorMsg = msg;
          } else if (msg != null) {
            errorMsg = msg.toString();
          }
        } catch (_) {}
        EasyLoading.showError(errorMsg);
      }
    } catch (error) {
      EasyLoading.showError('Update error: $error');
      debugPrint('❌ Exception updating profile: $error');
    }
  }

  TextEditingController getControllerForIndex(int index) {
    switch (index) {
      case 0:
        return firstNameController;
      case 1:
        return lastNameController;
      case 2:
        return dobController;
      case 3:
        return usernameController;
      case 4:
        return emailController;
      case 5:
        return phoneController;
      default:
        return TextEditingController();
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint('📌 ProfileController initialized');
    fetchUserProfile();
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.onClose();
  }
}

// ================= MODELS =================
class ProfileModel {
  final String title;
  final String subtitle;
  ProfileModel({required this.title, required this.subtitle});

  Map<String, dynamic> toJson() => {'title': title, 'subtitle': subtitle};
}

class UserModel {
  final String username;
  final String email;
  final String phone;
  final String image;
  userProfileModel? userProfile;

  UserModel({
    required this.username,
    required this.email,
    required this.phone,
    required this.image,
    this.userProfile,
  });

  factory UserModel.fromJsonData(Map<String, dynamic> data) {
    debugPrint('inside model parsing: $data');
    debugPrint('inside profile model parsing: ${data['profile']}');
    return UserModel(
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      image: data['image'] ?? '',
      userProfile: data['profile'] != null
          ? userProfileModel.fromJsonData(data['profile'])
          : null, // ✅ handle null
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'phone': phone,
    'image': image,
  };
}

class userProfileModel {
  final String firstName;
  final String lastName;
  final String dateOfBirth;
  userProfileModel({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
  });
  factory userProfileModel.fromJsonData(Map<String, dynamic> data) {
    return userProfileModel(
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      dateOfBirth: data['dob'] ?? '',
    );
  }
}
