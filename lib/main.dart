import 'package:flutter/material.dart';
import 'package:new_project_2025/app/Modules/login/login_page.dart';
import 'package:new_project_2025/view/home/widget/home_screen.dart';
import 'package:new_project_2025/view/home/widget/More_page/CheckPattern.dart';
import 'package:new_project_2025/view_model/Task/notificationservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize Local Notification
  final notificationService = NotificationService();
  await notificationService.initNotification();

  tz.initializeTimeZones();

  /// Android Notification Channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAVE App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: SplashPage(),
    );
  }
}

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    delayedFunction();
  }

  /// 🔥 Example: Trigger Local Notification manually
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      "Welcome",
      "App Started Successfully",
      platformDetails,
    );
  }

  Future<void> delayedFunction() async {
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    bool? appLockEnabled = prefs.getBool('app_lock_enabled');

    debugPrint('Token: $token');
    debugPrint('App Lock Enabled: $appLockEnabled');

    /// Optional: show notification
    await showTestNotification();

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else if (appLockEnabled == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CheckPattern()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SaveApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset("assets/Invoice.jpg")),
    );
  }
}
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:new_project_2025/app/Modules/login/login_page.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
// import 'package:new_project_2025/view/home/widget/More_page/CheckPattern.dart';
// import 'package:new_project_2025/view_model/Task/notificationservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
//
// import 'firebase_options.dart';
//
// final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =FlutterLocalNotificationsPlugin();
//
// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   final notificationService = NotificationService();
//   await notificationService.initNotification();
//
//   tz.initializeTimeZones();
//   await Firebase.initializeApp();
//
//   options: DefaultFirebaseOptions.currentPlatform;
//
//   // Now you can access FirebaseMessaging
//   await FirebaseMessaging.instance.subscribeToTopic("Sample");
//   const AndroidNotificationChannel channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     importance: Importance.high,
//   );
//   await _flutterLocalNotificationsPlugin.initialize(
//     const InitializationSettings(
//       android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//     ),
//   );
//
//   await _flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//       AndroidFlutterLocalNotificationsPlugin>()
//       ?.createNotificationChannel(channel);
//  // runApp(const MaterialApp(home: PushNotificationService()));
//  runApp(MyApp(notificationService: notificationService));
// }
//
//
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key, required NotificationService notificationService}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'SAVE App',
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: SplashPage(),
//     );
//   }
// }
//
// class SplashPage extends StatefulWidget {
//   @override
//   _SplashPageState createState() => _SplashPageState();
// }
//
// class _SplashPageState extends State<SplashPage> {
//   late final FirebaseMessaging _fcm;
//
//   @override
//   void initState() {
//     super.initState();
//     delayedFunction();
//     _fcm = FirebaseMessaging.instance;
//     _initializeNotifications();
//
//   }
//   Future<void> _initializeNotifications() async {
//     // Request permissions (required for Android 13+ and iOS)
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ Notification permission granted');
//     } else {
//       print('❌ Notification permission denied');
//     }
//
//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📬 Message received in foreground: ${message.notification?.title}');
//       _showLocalNotification(message);
//     });
//
//     // When user taps the notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('📲 Notification clicked: ${message.notification?.title}');
//     });
//
//     // Get token
//     String? token = await _fcm.getToken();
//     print('🔑 FCM Token: $token');
//   }
//
//   /// Show local notification popup when app is open
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//     );
//
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//       platformDetails,
//     );
//   }
//
//   Future<void> delayedFunction() async {
//     await Future.delayed(Duration(seconds: 3));
//
//     final prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString('token');
//     bool? appLockEnabled = prefs.getBool('app_lock_enabled');
//
//     debugPrint('Token in SplashPage: $token');
//     debugPrint('App Lock Enabled: $appLockEnabled');
//
//     if (token == null || token.isEmpty) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//     } else if (appLockEnabled == true) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => CheckPattern()),
//       );
//     } else {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SaveApp()),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Center(child: Image.asset("assets/Invoice.jpg")));
//   }
// }
//FCM

//
// class PushNotificationService extends StatefulWidget {
//   const PushNotificationService({super.key});
//
//   @override
//   State<PushNotificationService> createState() =>
//       _PushNotificationServiceState();
// }
//
// class _PushNotificationServiceState extends State<PushNotificationService> {
//   late final FirebaseMessaging _fcm;
//
//   @override
//   void initState() {
//     super.initState();
//     _fcm = FirebaseMessaging.instance;
//     _initializeNotifications();
//   }
//
//   Future<void> _initializeNotifications() async {
//     // Request permissions (required for Android 13+ and iOS)
//     NotificationSettings settings = await _fcm.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('✅ Notification permission granted');
//     } else {
//       print('❌ Notification permission denied');
//     }
//
//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📬 Message received in foreground: ${message.notification?.title}');
//       _showLocalNotification(message);
//     });
//
//     // When user taps the notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('📲 Notification clicked: ${message.notification?.title}');
//     });
//
//     // Get token
//     String? token = await _fcm.getToken();
//     print('🔑 FCM Token: $token');
//   }
//
//   /// Show local notification popup when app is open
//   Future<void> _showLocalNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidDetails =
//     AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: true,
//     );
//
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
//
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? 'No Title',
//       message.notification?.body ?? 'No Body',
//       platformDetails,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Push Notification Service'),
//       ),
//       body: const Center(
//         child: Text(
//           'Waiting for push notifications...',
//           style: TextStyle(fontSize: 18),
//         ),
//       ),
//     );
//   }
// }
//
