import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'logger_service.dart';

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
  static const String _adminTopic = 'admin';
  static const String _userTopic = 'user';

  final FirebaseMessaging _messaging;
  final SharedPreferences _prefs;
  final Logger _logger = LoggerService.getLogger();

  NotificationService({
    FirebaseMessaging? messaging,
    required SharedPreferences prefs,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _prefs = prefs;

  Future<T> _handleNotificationOperation<T>(
    Future<T> Function() operation, {
    String operationName = 'Notification operation',
  }) async {
    try {
      return await operation();
    } catch (e) {
      _logger.e('Failed $operationName: $e');
      throw NotificationServiceException(
        message: 'Error occurred during $operationName',
        details: e.toString(),
      );
    }
  }

  Future<void> init() async {
    if (kIsWeb) {
      // Web-Push vorerst deaktiviert
      return;
    }

    // Request permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // First register for Remote Notifications
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // Get APNS Token for iOS
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1)); // Wait a moment
        String? apnsToken = await _messaging.getAPNSToken();
        print('APNS Token: $apnsToken');
      }

      // Configure foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
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

  void _handleForegroundMessage(RemoteMessage message) {
    // Here you can process the message, e.g. display a local notification
    print('Received foreground message: ${message.notification?.title}');
  }
}
