// import 'package:get/get.dart';
// import 'package:nicholaslim80/core/api_end_point/api_end_point.dart';

// class MyRidersService extends GetConnect {
//   @override
//   void onInit() {
//     httpClient.baseUrl = ApiEndPoint.baseUrl;
//     httpClient.timeout = const Duration(seconds: 20);
//     super.onInit();
//   }

//   Future<Response> addRider({
//     required String token,
//     required String findBy,
//     required bool isFav,
//   }) {
//     return post(
//       ApiEndPoint.addRaider,
//       {
//         "find_by": findBy,
//         "is_fav": isFav,
//       },
//       headers: {
//         "Authorization": "Bearer $token",
//         "Content-Type": "application/json",
//         "accept": "*/*",
//       },
//     );
//   }
// }
