import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationServiceException implements Exception {
  final String message;
  final String? code;
  final String? details;

  NotificationServiceException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() =>
      'NotificationServiceException: $message\nCode: $code\nDetails: $details';
}

class NotificationService {
  final FirebaseMessaging _messaging;
  final SharedPreferences _prefs;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  NotificationService({
    FirebaseMessaging? messaging,
    required SharedPreferences prefs,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _prefs = prefs;

  Future<void> init() async {
    if (kIsWeb) {
      // Web-Push vorerst deaktiviert
      return;
    }

    try {
      // Request permissions
      final NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // First register for Remote Notifications
        await _messaging.setAutoInitEnabled(true);

        // Get the token
        String? token = await _messaging.getToken();
        _logger.d('Firebase Messaging token: $token');

        // Get APNS Token for iOS
        if (Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          _logger.d('APNS Token: $apnsToken');
        }

        // Subscribe to topics if needed
        await _subscribeToTopics();

        // Handle background messages
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _logger.d('Received foreground message: ${message.notification?.title}');
          // Handle the message as needed
        });

        // Handle message when app is in background but not terminated
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _logger.d('Message tapped: ${message.notification?.title}');
          // Handle the message as needed
        });
      } else {
        _logger.w('User declined notification permissions');
      }
    } catch (e) {
      _logger.e('Failed to initialize notifications: $e');
      throw NotificationServiceException(
        message: 'Failed to initialize notifications',
        details: e.toString(),
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle background message
    print('Handling background message: ${message.notification?.title}');
  }

  Future<void> _subscribeToTopics() async {
    try {
      // Subscribe to general topics
      await _messaging.subscribeToTopic('general');
      
      // Subscribe to any specific topics based on user preferences
      final List<String> subscribedWalls = _prefs.getStringList('subscribed_walls') ?? [];
      for (String wallId in subscribedWalls) {
        await _messaging.subscribeToTopic('wall_$wallId');
      }
    } catch (e) {
      _logger.e('Failed to subscribe to topics: $e');
    }
  }

  Future<void> subscribeToWall(String wallId) async {
    if (kIsWeb) {
      // Web-Push vorerst deaktiviert
      return;
    }

    final key = 'subscribed_$wallId';
    final alreadySubscribed = _prefs.getBool(key) ?? false;

    if (!alreadySubscribed) {
      await _messaging.subscribeToTopic('wall_$wallId');
      await _prefs.setBool(key, true);
    }
  }

  Future<void> unsubscribeFromWall(String wallId) async {
    await _messaging.unsubscribeFromTopic('wall_$wallId');
    await _prefs.setBool('subscribed_$wallId', false);
  }


}
