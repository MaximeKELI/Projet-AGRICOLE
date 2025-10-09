import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static StreamController<Map<String, dynamic>> _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream pour écouter les notifications
  static Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  // Initialiser le service de notifications
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        linux: LinuxInitializationSettings(
          defaultActionName: 'Open notification',
        ),
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation des notifications: $e');
      // Continuer sans notifications sur les plateformes non supportées
      _isInitialized = true;
    }
  }

  // Gérer le tap sur une notification
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = Map<String, dynamic>.from(response.payload as Map);
        _notificationController.add(data);
      } catch (e) {
        print('Erreur parsing payload notification: $e');
      }
    }
  }

  // Afficher une notification locale
  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? channelId = 'agricultural_channel',
    String? channelName = 'Notifications Agricoles',
    String? channelDescription = 'Notifications pour l\'application agricole',
  }) async {
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'agricultural_channel',
      'Notifications Agricoles',
      channelDescription: 'Notifications pour l\'application agricole',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Afficher une notification de météo
  static Future<void> showWeatherAlert({
    required String title,
    required String message,
    required String severity, // low, medium, high
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'weather',
      'severity': severity,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await showLocalNotification(
      id: id,
      title: title,
      body: message,
      payload: payload,
      channelId: 'weather_alerts',
      channelName: 'Alertes Météo',
      channelDescription: 'Alertes météorologiques importantes',
    );
  }

  // Afficher une notification de recommandation IA
  static Future<void> showAIRecommendation({
    required String title,
    required String message,
    required String priority, // low, medium, high
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'ai_recommendation',
      'priority': priority,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await showLocalNotification(
      id: id,
      title: title,
      body: message,
      payload: payload,
      channelId: 'ai_recommendations',
      channelName: 'Recommandations IA',
      channelDescription: 'Suggestions intelligentes pour vos cultures',
    );
  }

  // Afficher une notification de commande
  static Future<void> showOrderNotification({
    required String orderId,
    required String status,
    required String message,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'order',
      'orderId': orderId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await showLocalNotification(
      id: id,
      title: 'Commande #$orderId',
      body: message,
      payload: payload,
      channelId: 'orders',
      channelName: 'Commandes',
      channelDescription: 'Notifications de commandes et livraisons',
    );
  }

  // Afficher une notification de paiement
  static Future<void> showPaymentNotification({
    required String transactionId,
    required String status,
    required double amount,
    required String currency,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'payment',
      'transactionId': transactionId,
      'status': status,
      'amount': amount,
      'currency': currency,
      'timestamp': DateTime.now().toIso8601String(),
    });

    String title = 'Paiement ${status == 'completed' ? 'réussi' : 'échoué'}';
    String body = '${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)} $currency';

    await showLocalNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelId: 'payments',
      channelName: 'Paiements',
      channelDescription: 'Notifications de paiements et transactions',
    );
  }

  // Afficher une notification de livraison
  static Future<void> showDeliveryNotification({
    required String shipmentId,
    required String status,
    required String message,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'delivery',
      'shipmentId': shipmentId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await showLocalNotification(
      id: id,
      title: 'Livraison #$shipmentId',
      body: message,
      payload: payload,
      channelId: 'deliveries',
      channelName: 'Livraisons',
      channelDescription: 'Suivi des livraisons et expéditions',
    );
  }

  // Afficher une notification de certification
  static Future<void> showCertificationNotification({
    required String certificationId,
    required String status,
    required String message,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    final payload = jsonEncode({
      'type': 'certification',
      'certificationId': certificationId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await showLocalNotification(
      id: id,
      title: 'Certification $status',
      body: message,
      payload: payload,
      channelId: 'certifications',
      channelName: 'Certifications',
      channelDescription: 'Notifications de certifications et qualité',
    );
  }

  // Programmer une notification
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    await initialize();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Notifications Programmées',
      channelDescription: 'Notifications programmées pour l\'application agricole',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledDate,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Annuler une notification
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  // Annuler toutes les notifications
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Obtenir les notifications en attente
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Vérifier les permissions
  static Future<bool> requestPermissions() async {
    await initialize();
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    
    return true; // iOS gère les permissions différemment
  }

  // Afficher une notification de test
  static Future<void> showTestNotification() async {
    await showLocalNotification(
      id: 999,
      title: 'Test de Notification',
      body: 'Ceci est une notification de test pour vérifier le bon fonctionnement du système.',
      payload: jsonEncode({
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // Nettoyer les notifications anciennes
  static Future<void> cleanupOldNotifications() async {
    final pending = await getPendingNotifications();
    final now = DateTime.now();
    
    for (var notification in pending) {
      // Supprimer les notifications programmées de plus de 7 jours
      if (notification.id < now.subtract(const Duration(days: 7)).millisecondsSinceEpoch) {
        await cancelNotification(notification.id);
      }
    }
  }
}
