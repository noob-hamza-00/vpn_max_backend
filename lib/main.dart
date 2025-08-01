import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'View/splash_screen.dart';
import 'providers/ads_provider.dart';
import 'providers/animation_provider.dart';
import 'providers/apps_provider.dart';
import 'providers/device_detail_provider.dart';
import 'providers/servers_provider.dart';
import 'providers/vpn_connection_provider.dart';
import 'providers/vpn_provider.dart';
import 'utils/preferences.dart';

// Workmanager callback function
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    // Handle background task here
    return Future.value(true);
  });
}

void main() async {
  runZonedGuarded(() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize SharedPreferences early
      await SharedPreferences.getInstance();
      
      // Initialize Prefs utility class
      await Prefs.init();
      
      // Initialize Google Mobile Ads
      await MobileAds.instance.initialize();
      
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF212121),
      ));

      // Set preferred orientations
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown
      ]);

      runApp(const MyApp());
      
    } catch (e, stackTrace) {
      // Show error screen if initialization fails
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      runApp(MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Initialization Error',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Error: $e',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ));
    }
  }, (error, stack) {
    // Handle uncaught errors
    debugPrint('Uncaught error: $error');
    debugPrint('Stack trace: $stack');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdsProvider()),
        ChangeNotifierProvider(create: (_) => CountProvider()),
        ChangeNotifierProvider(create: (_) => AppsProvider()),
        ChangeNotifierProvider(create: (_) => DeviceDetailProvider()),
        ChangeNotifierProvider(create: (_) => ServersProvider()),
        ChangeNotifierProvider(create: (_) => VpnConnectionProvider()),
        ChangeNotifierProvider(create: (_) => VpnProvider()),
      ],
      child: MaterialApp(
        title: 'VPN Max',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}