import 'package:dio/dio.dart';

class WebhookService {
  static const String _n8nWebhookUrl =
      'https://megahack.app.n8n.cloud/webhook/cb7d7971-c81f-4472-8520-d8c64e37263d';

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Trigger AI calling agent via webhook
  static Future<void> triggerAICall({
    required String userName,
    required String userPhone,
    required String userEmail,
    required String clinicName,
    String action = 'call_button_clicked',
  }) async {
    try {
      final payload = {
        'name': userName,
        'phone': userPhone,
        'email': userEmail,
        'clinic': clinicName,
        'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await _dio.post(
        _n8nWebhookUrl,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        print('AI call triggered successfully');
      } else {
        print('Webhook response: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Error triggering AI call: $e');
      rethrow;
    }
  }

  /// Send appointment booking request via webhook
  static Future<void> bookAppointmentViaAI({
    required String userName,
    required String userPhone,
    required String userEmail,
    required String clinicName,
    String? preferredTime,
  }) async {
    try {
      final payload = {
        'name': userName,
        'phone': userPhone,
        'email': userEmail,
        'clinic': clinicName,
        'action': 'appointment_booking',
        'preferred_time': preferredTime,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _dio.post(
        _n8nWebhookUrl,
        data: payload,
      );

      print('Appointment booking triggered via AI');
    } catch (e) {
      print('Error booking appointment via AI: $e');
      rethrow;
    }
  }

  /// Send SMS notification via webhook
  static Future<void> sendSmsNotification({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final payload = {
        'phone': phoneNumber,
        'message': message,
        'action': 'send_sms',
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _dio.post(
        _n8nWebhookUrl,
        data: payload,
      );

      print('SMS notification sent');
    } catch (e) {
      print('Error sending SMS notification: $e');
      rethrow;
    }
  }
}
