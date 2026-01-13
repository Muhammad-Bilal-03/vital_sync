import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di.dart';
import 'core/theme.dart';
import 'core/seeder.dart'; // Import the seeder
import 'repositories/auth_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/notification_repository.dart';
import 'providers/user_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 1. Initialize Service Locator
  await setupLocator();

  // 2. Run Seeder (Checks if empty first)
  await DataSeeder().seedTests();

  runApp(const VitalSyncApp());
}

class VitalSyncApp extends StatelessWidget {
  const VitalSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 2. Inject Repositories via Constructor
        ChangeNotifierProvider(
          create: (_) => UserProvider(getIt<BaseAuthRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(getIt<SharedPreferences>()),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(getIt<OrderRepository>()),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(getIt<NotificationRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'VitalSync',
        debugShowCheckedModeBanner: false,
        theme: VitalTheme.lightTheme,
        // CHANGED: Use RootWrapper instead of LoginScreen directly
        home: const RootWrapper(),
      ),
    );
  }
}

// ------------------------------------------
// NEW: Root Wrapper for Safe Initialization
// ------------------------------------------
class RootWrapper extends StatefulWidget {
  const RootWrapper({super.key});

  @override
  State<RootWrapper> createState() => _RootWrapperState();
}

class _RootWrapperState extends State<RootWrapper> {
  @override
  void initState() {
    super.initState();
    // This is the Safe Architecture Way:
    // Listen to Auth changes. When a user logs in, fetch their data.
    final authRepo = getIt<BaseAuthRepository>();
    authRepo.authStateChanges.listen((user) {
      if (user != null) {
        if (mounted) {
          // Initialize Global Data securely here
          Provider.of<OrderProvider>(context, listen: false)
              .initOrders(user.uid);
          Provider.of<NotificationProvider>(context, listen: false)
              .initNotifications(user.uid);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to the auth stream to decide which screen to show
    return StreamBuilder(
      stream: getIt<BaseAuthRepository>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
