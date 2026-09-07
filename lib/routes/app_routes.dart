// import 'package:ZipBee/features/kamrul_express/screen/kamrul_express_screen.dart';
import 'package:ZipBee/features/onboarding/screen/onboarding_screen.dart';
import 'package:ZipBee/features/orders/completed_order_details/proof_of_delivery/binding/proof_of_delivery_binding.dart';
import 'package:ZipBee/features/orders/completed_order_details/proof_of_delivery/screen/proof_of_delivery_screen2.dart';
import 'package:ZipBee/features/splash/screen/splash_screen.dart';
import 'package:ZipBee/features/user/auth/forgotPassword/screen/forgot_password_screen.dart';
import 'package:ZipBee/features/user/auth/login/screen/login_signup_screen.dart';
import 'package:ZipBee/features/user/auth/reset_password/screen/reset_password_screen.dart';
import 'package:ZipBee/features/user/auth/verification/screen/verification_screen.dart';
import 'package:ZipBee/features/user/bottom_navbar/screen/bottom_navbar_screen.dart';
import 'package:ZipBee/features/user/chat/screen/chat_screen.dart';
import 'package:ZipBee/features/user/express_delivery_1/express_delivery_to_sendr_or_recepmeant/screen/express_sender_or_recepmeant.dart';
import 'package:ZipBee/features/user/finding_raider/screnn/connecting_rider_page.dart'
    show ConnectingRiderPage;
import 'package:ZipBee/features/user/finding_raider/screnn/finding_rider_page.dart';
import 'package:ZipBee/features/user/google_map/screen/google_map_screen.dart';
import 'package:ZipBee/features/user/home/controller/home_controller.dart';
import 'package:ZipBee/features/user/my_riders/screen/my_riders.dart';
import 'package:ZipBee/features/user/home/screen/home_screen.dart';
import 'package:ZipBee/features/user/notification/screen/user_notification1.dart';
import 'package:ZipBee/features/user/profile/screen/profile_screen.dart';
import 'package:ZipBee/features/user/refer_and_earn/screen/refer_and_earn_screen.dart';
import 'package:ZipBee/features/user/saved_places/screen/saved_place_screenn.dart';
// import 'package:ZipBee/features/user/stacked/FAQ/express_faq.dart';
// import 'package:ZipBee/features/user/stacked/FAQ/stacked_faq.dart';
// import 'package:ZipBee/features/user/stacked/FAQ/standard_faq.dart';
import 'package:ZipBee/features/user/stacked/schedule_stacked_%20delivey/Schedule_recepent/screen/schedule_recepent_screen1.dart';
import 'package:ZipBee/features/user/user_support/screen/support_screen.dart';
import 'package:ZipBee/features/user/wallet/add_funds/screen/user_add_funds.dart';
import 'package:ZipBee/features/user/wallet/my_wallet/screen/user_my_wallet.dart';
import 'package:get/get.dart';
import '../features/user/stacked/stacked_screen/stacked_screen.dart';

class AppRoutes {
  static String kamrulExpressScreen = '/kamrulExpressScreen';

  static String splashScreen = '/splashScreen';
  static String onboardingScreen = '/onboardingScreen';
  static String proofOfDeliveryScreen = '/proofOfDeliveryScreen';
  static String loginScreen = '/loginScreen';
  static String verificationScreen = '/verificationScreen';
  static String homeScreen = '/homeScreen';
  static String resetPasswordScreen = '/resetPasswordScreen';
  static String forgotPasswordScreen = '/forgotPasswordScreen';
  static String ordersScreen = '/ordersScreen';
  static String accountScreen = '/accountScreen';
  static String bottomNavbarScreen = '/bottomnavbarScreen';
  static String appQuizScreen = '/appQuizScreen';
  static String appCouresScreen = '/appCouresScreen';
  static String quizCongratulationScreen = '/quizCongratulationScreen';
  static String tryAginScreen = '/tryAginScreen';
  static String driverPreferenceScreen = '/driverPreferenceScreen';
  static String distanceRadiusScreen = '/distanceRadiusScreen';
  static String referAndEarnScreen = '/referAndEarnScreen';
  static String myRidersScreen = '/myRidersScreen';
  static String supportScreen = '/supportScreen';
  static String findingRider = '/finding-rider';
  static String connectingRider = '/connecting-rider';
  static String stackedScreen = '/stackedScreen';
  static String stackedFAQScreen = '/stackedFAQScreen';

  static String riderBottomNavbarScreen = '/riderBottomNavbarScreen';
  static String riderHomeScreen = '/riderHomeScreen';
  static String incentivesScreen = '/incentivesScreen';
  static String recordsScreen = '/recordsScreen';
  static String riderAccountScreen = '/riderAccountScreen';
  static String chatScreen = '/chatScreen';

  //user notification
  static String userNotification = '/user/notification';
  static String userOrderDetails = '/userOrderDetails';
  static String savedPlaces = '/savedPlaces';
  //user wallet
  static String myWalletUser = "/User/myWalletUser";
  static String userAddFund = "/user/userAddFund";
  //express delivery
  static String expressDelivery1 = "/expressDelivery1";
  static String expressFaq = "/expressFaq";
  static String expressSenderOrRecepment = "/expressSenderOrRecepment";
  static String savedPlaceScreen = "/savedPlaceScreen";

  // google map screen (practice file)
  static String googleMapScreen = "/googleMapScreen";

  static String stackedSchedulRecepmenteScreen =
      "/stackedSchedulRecepmenteScreen";
  static String standardFAQ = "/standardFAQ";

  // static String scheduledelivery = "/scheduledelivery";

  static String getKamrulExpressScreen() => kamrulExpressScreen;

  static String getSplashScreen() => splashScreen;
  static String getOnboardingScreen() => onboardingScreen;
  static String getProofOfDeliveryScreen() => proofOfDeliveryScreen;
  static String getLoginScreen() => loginScreen;
  static String getverificationScreen() => verificationScreen;
  static String gethomeScreen() => homeScreen;
  static String getResetPasswordScreen() => resetPasswordScreen;
  static String getordersScreen() => ordersScreen;
  static String getaccountScreen() => accountScreen;
  static String getbottomNavbarScreen() => bottomNavbarScreen;
  static String getappQuizScreen() => appQuizScreen;
  static String getappCouresScreen() => appCouresScreen;
  static String getquizCongratulationScreen() => quizCongratulationScreen;
  static String gettryAginScreen() => tryAginScreen;
  static String getdriverPreferenceScreen() => driverPreferenceScreen;
  static String getdistanceRadiusScreen() => distanceRadiusScreen;
  static String getexpressDelivery1() => expressDelivery1;
  static String getexpressFaq() => expressFaq;
  static String getstackedScreen() => stackedScreen;

  static String getriderBottomNavbarScreen() => riderBottomNavbarScreen;
  static String getriderHomeScreen() => riderHomeScreen;
  static String getincentivesScreen() => incentivesScreen;
  static String getrecordsScreen() => recordsScreen;
  static String getriderAccountScreen() => riderAccountScreen;
  static String getreferAndEarnScreen() => referAndEarnScreen;
  static String getrstackedFAQScreen() => stackedFAQScreen;

  static String getsavedPlaceScreen() => savedPlaceScreen;

  //user notification
  static String getUserNotification() => userNotification;
  static String getSavedPlaces() => savedPlaces;
  //user my wallet
  static String getmyWalletUser() => myWalletUser;
  static String getuserAddFund() => userAddFund;
  //express delivery
  static String getexpressSenderOrRecepment() => expressSenderOrRecepment;
  static String getconnectingRider() => connectingRider;
  static String getfindingRider() => findingRider;
  static String getstandardFAQ() => standardFAQ;
  // static String scheduledelivery() => scheduledelivery;

  static List<GetPage> routes = [
    // GetPage(name: kamrulExpressScreen, page: () => KamrulExpressScreen()),

    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: onboardingScreen, page: () => OnboardingScreen()),
    GetPage(
      name: loginScreen,
      page: () => LoginSignupScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: verificationScreen,
      page: () => VerificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: homeScreen,
      page: () => HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: resetPasswordScreen,
      page: () => ResetPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPasswordScreen,
      page: () => ForgotPasswordScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: ordersScreen,
      page: () => OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/ProofOfDeliveryScreen2',
      page: () => ProofOfDeliveryScreen2(),
      binding: ProofOfDeliveryBinding(),
    ),

    GetPage(
      name: accountScreen,
      page: () => ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: bottomNavbarScreen,
      page: () => BottomNavbarScreen(),
      transition: Transition.fadeIn,
      binding: BindingsBuilder(() {
        Get.put<HomeController>(HomeController(), permanent: true);
      }),
    ),

    GetPage(
      name: referAndEarnScreen,
      page: () => ReferAndEarnScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: stackedScreen,
      page: () => StackedScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: myRidersScreen,
      page: () => MyRidersScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: supportScreen,
      page: () => SupportScreen(),
      transition: Transition.fadeIn,
    ),

    //user notification
    GetPage(name: userNotification, page: () => UserNotification()),
    GetPage(name: savedPlaces, page: () => SavedPlaceScreen()),
    //user my wallet
    GetPage(name: myWalletUser, page: () => UserMyWallet()),
    GetPage(name: userAddFund, page: () => UserAddFunds()),
    //express delivery
    GetPage(
      name: expressSenderOrRecepment,
      page: () => ExpressToSenderOrRecepment(),
    ),
    GetPage(name: connectingRider, page: () => ConnectingRiderPage()),
    GetPage(name: findingRider, page: () => FindingRiderPage()),
    GetPage(
      name: savedPlaceScreen,
      page: () => SavedPlaceScreen(),
      transition: Transition.fadeIn,
    ),

    // google map screen (practice file)
    GetPage(name: googleMapScreen, page: () => GoogleMapScreen()),
    GetPage(name: chatScreen, page: () => ChatScreen()),

    // Schedule Recipient Screen
    GetPage(
      name: stackedSchedulRecepmenteScreen,
      page: () => StackedSchedulRecepmenteScreen(),
    ),

    // Schedule Sender Screen
  ];
}
