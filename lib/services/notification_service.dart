import 'dart:io' show Platform;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final SharedPreferences _prefs;

  NotificationService(this._prefs);

  Future<void> init() async {
    if (kIsWeb) {
      // Web-Push vorerst deaktiviert
      return;
    }

    // Berechtigungen anfordern
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Erst für Remote Notifications registrieren
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      // APNS Token für iOS abrufen
      if (Platform.isIOS) {
        await Future.delayed(const Duration(seconds: 1)); // Kurz warten
        String? apnsToken = await _messaging.getAPNSToken();
        print('APNS Token: $apnsToken');
      }

      // Foreground Nachrichten konfigurieren
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
    // Hier können Sie die Nachricht verarbeiten, z.B. eine lokale Notification anzeigen
    print('Received foreground message: ${message.notification?.title}');
  }
}
