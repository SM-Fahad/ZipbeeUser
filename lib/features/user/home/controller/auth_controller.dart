import 'package:ZipBee/core/api_end_point/api_end_point.dart';
import 'package:ZipBee/core/shared_prefference_service/shared_pref.dart';
import 'package:ZipBee/features/user/home/controller/popup_controller.dart';
import 'package:ZipBee/features/user/home/widgets/logout_dailog_widget.dart';
import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  void showLogoutDialog() {
   Get.dialog(
     LogoutDialog(
       onConfirm: () => logout(),
     ),
     barrierDismissible: false,
   );
 }

 // Logout Process    
 Future<void> logout() async {
   try {
     final token = await SharedPreferencesHelper.getAccessToken();

     if (token != null && token.isNotEmpty) {
       final response = await http.post(
         Uri.parse(ApiEndPoint.logOut),
         headers: {
           "Authorization": "Bearer $token",
           "Content-Type": "application/json",
         },
       );

       if (response.statusCode == 200) {
         debugPrint("Logout API success");
       } else {
         debugPrint("Logout API failed: ${response.statusCode}");
       }
     }
   } catch (e) {
     debugPrint("LOGOUT ERROR: $e");
   } finally {
     PopupController.resetPopupState();
     await SharedPreferencesHelper.logout();
     Get.offAllNamed(AppRoutes.loginScreen);
   }
 }
}