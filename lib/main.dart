import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService(prefs: prefs);
  final storageService = StorageService(prefs);
  await notificationService.init();

  runApp(MyApp(
    router: getRouter(notificationService, storageService),
    notificationService: notificationService,
  ));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  final GoRouter router;

  const MyApp({
    super.key,
    required this.notificationService,
    required this.router,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: getAppTheme(),
      routerConfig: router,
    );
  }
}
