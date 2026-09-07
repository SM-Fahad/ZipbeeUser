import 'package:ZipBee/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/bindings/controller_binder.dart';

class Nicholaslim extends StatelessWidget {
  const Nicholaslim({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: "ZipBee",
          debugShowCheckedModeBanner: false,
          builder: EasyLoading.init(),
          initialRoute: AppRoutes.getSplashScreen(),

          // initialRoute: AppRoutes.googleMapScreen, // for testing google map
          getPages: AppRoutes.routes,

          initialBinding: ControllerBinder(),

          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
