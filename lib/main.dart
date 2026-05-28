import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:restaurant_app/firebase_options.dart';
import 'package:restaurant_app/providers/cart_provider.dart';
import 'package:restaurant_app/providers/auth_provider.dart';
import 'package:restaurant_app/providers/favorites_provider.dart';
import 'package:restaurant_app/providers/staff_provider.dart';
import 'package:restaurant_app/services/firestore_service.dart';
import 'package:restaurant_app/services/order_service.dart';
import 'package:restaurant_app/services/sample_data_service.dart';
import 'package:restaurant_app/services/manager_service.dart';
import 'package:restaurant_app/screens/app_selector_screen.dart';
import 'package:restaurant_app/services/notification_service.dart';
import 'package:restaurant_app/services/dasher_assignment_service.dart';
import 'package:restaurant_app/services/menu_management_service.dart';
// import 'package:restaurant_app/services/stripe_service.dart'; // Removed for web compatibility
//import 'package:restaurant_app/screens/mapsample.dart';

import 'package:restaurant_app/screens/screens_1/changeAddressScreen.dart';
import 'package:restaurant_app/screens/favorites_screen.dart';

import 'package:restaurant_app/screens/screens_1/landingScreen.dart';
import 'package:restaurant_app/screens/screens_1/loginScreen.dart';
import 'package:restaurant_app/screens/screens_1/signUpscreen.dart';
//import 'package:restaurant_app/screens/screens_1/registerScreen.dart';
import 'package:restaurant_app/screens/screens_1/forgetPwScreen.dart';
import 'package:restaurant_app/screens/screens_1/sentOTPScreen.dart';
import 'package:restaurant_app/screens/screens_1/newPwScreen.dart';
import 'package:restaurant_app/screens/screens_1/introScreen.dart';
import 'package:restaurant_app/screens/screens_1/homeScreen.dart';
import 'package:restaurant_app/screens/screens_1/menuScreen.dart';
import 'package:restaurant_app/screens/enhanced_home_screen.dart';
import 'package:restaurant_app/screens/screens_1/moreScreen.dart';
import 'package:restaurant_app/screens/screens_1/offerScreen.dart';
import 'package:restaurant_app/screens/screens_1/profileScreen.dart';
import 'package:restaurant_app/screens/screens_1/dessertScreen.dart';
import 'package:restaurant_app/screens/screens_1/individualItem.dart';
import 'package:restaurant_app/screens/screens_1/paymentScreen.dart';
import 'package:restaurant_app/screens/screens_1/notificationScreen.dart';
import 'package:restaurant_app/screens/screens_1/aboutScreen.dart';
import 'package:restaurant_app/screens/screens_1/inboxScreen.dart';
import 'package:restaurant_app/screens/screens_1/myOrderScreen.dart';
import 'package:restaurant_app/screens/screens_1/checkoutScreen.dart';
import 'package:restaurant_app/screens/today_orders_screen.dart';
import 'package:restaurant_app/screens/active_restaurants_screen.dart';
import 'package:restaurant_app/screens/active_dashers_screen.dart';
import 'package:restaurant_app/screens/revenue_details_screen.dart';
// Add this import with the other screen imports around line 60
import 'package:restaurant_app/screens/view_reports_screen.dart';

// Add this import
import 'package:restaurant_app/services/offer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late final SampleDataService sampleDataService;

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize Stripe configuration - Removed for web compatibility
    // await StripeService.init();
    // print('Stripe initialized successfully');

    // REMOVE THIS: Initialize sample data (includes all services)
    // sampleDataService = SampleDataService();
    // await sampleDataService.initializeSampleData();
    // print('Sample data initialized successfully');
  } catch (e) {
    print('Error during initialization: $e');
    return;
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      Provider<FirestoreService>(create: (_) => FirestoreService()),
      ChangeNotifierProvider<OrderService>(create: (_) => OrderService()),
      // REMOVE THIS: Provider<SampleDataService>(create: (_) => sampleDataService),
      Provider<NotificationService>(create: (_) => NotificationService()),
      Provider<DasherAssignmentService>(
          create: (_) => DasherAssignmentService()),
      Provider<MenuManagementService>(create: (_) => MenuManagementService()),
      Provider<ManagerService>(create: (_) => ManagerService()),
      ChangeNotifierProvider(create: (_) => StaffProvider()),

      // below code from other app to integrate
      Provider<LandingScreen>(create: (_) => LandingScreen()),
      Provider<LoginScreen>(create: (_) => LoginScreen()),
      Provider<SignUpScreen>(create: (_) => SignUpScreen()),
      Provider<ForgetPwScreen>(create: (_) => ForgetPwScreen()),
      Provider<SendOTPScreen>(create: (_) => SendOTPScreen()),
      Provider<NewPwScreen>(create: (_) => NewPwScreen()),
      Provider<IntroScreen>(create: (_) => IntroScreen()),
      Provider<HomeScreen>(create: (_) => HomeScreen()),
      Provider<MenuScreen>(create: (_) => MenuScreen()),
      Provider<OfferScreen>(create: (_) => OfferScreen()),
      Provider<OfferService>(create: (_) => OfferService()),
      Provider<ProfileScreen>(create: (_) => ProfileScreen()),
      Provider<MoreScreen>(create: (_) => MoreScreen()),
      Provider<DessertScreen>(create: (_) => DessertScreen()),
      Provider<IndividualItem>(create: (_) => IndividualItem()),
      Provider<PaymentScreen>(create: (_) => PaymentScreen()),
      Provider<NotificationScreen>(create: (_) => NotificationScreen()),
      Provider<AboutScreen>(create: (_) => AboutScreen()),
      Provider<InboxScreen>(create: (_) => InboxScreen()),
      Provider<MyOrderScreen>(create: (_) => MyOrderScreen()),
      Provider<CheckoutScreen>(create: (_) => CheckoutScreen()),
      Provider<ChangeAddressScreen>(create: (_) => ChangeAddressScreen()),
      //Provider<MapSample>(create: (_) => MapSample()),
    ],
    child: MaterialApp(
      home: const AppSelectorScreen(),
      routes: {
        // Manager app routes
        '/active_restaurants': (context) => const ActiveRestaurantsScreen(),
        '/active_dashers': (context) => const ActiveDashersScreen(),
        '/today_orders': (context) => const TodayOrdersScreen(),
        '/revenue_details': (context) => const RevenueDetailsScreen(),
        '/view_reports': (context) => const ViewReportsScreen(),
        
        // Customer app routes
        '/offerScreen': (context) => const OfferScreen(),
        '/homeScreen': (context) => const EnhancedHomeScreen(),
        '/favoritesScreen': (context) => const FavoritesScreen(),
        '/profileScreen': (context) => const ProfileScreen(),
        '/moreScreen': (context) => const MoreScreen(),
        '/menuScreen': (context) => const MenuScreen(),
        '/dessertScreen': (context) => const DessertScreen(),
        '/paymentScreen': (context) => const PaymentScreen(),
        '/notificationScreen': (context) => const NotificationScreen(),
        '/aboutScreen': (context) => const AboutScreen(),
        '/inboxScreen': (context) => const InboxScreen(),
        '/myOrderScreen': (context) => const MyOrderScreen(),
        '/checkoutScreen': (context) => const CheckoutScreen(),
        '/changeAddressScreen': (context) => const ChangeAddressScreen(),
        
        // Auth routes
        '/landingScreen': (context) => const LandingScreen(),
        '/loginScreen': (context) => const LoginScreen(),
        '/signUpScreen': (context) => const SignUpScreen(),
        '/forgetPwScreen': (context) => const ForgetPwScreen(),
        '/sentOTPScreen': (context) => const SendOTPScreen(),
        '/newPwScreen': (context) => const NewPwScreen(),
        '/introScreen': (context) => const IntroScreen(),
      },
    ),
  ));
}
