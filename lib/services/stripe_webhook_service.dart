import 'dart:convert';
import 'package:http/http.dart' as http;

class StripeWebhookService {
  static const String _webhookSecret =
      String.fromEnvironment('STRIPE_WEBHOOK_SECRET', defaultValue: '');
  static const String _stripeSecretKey =
      String.fromEnvironment('STRIPE_SECRET_KEY', defaultValue: '');

  // Webhook endpoint handler (this would typically be on your backend)
  static Future<Map<String, dynamic>> handleWebhook(
    Map<String, dynamic> requestBody,
    String signature,
  ) async {
    try {
      // Verify webhook signature
      if (!_verifySignature(requestBody, signature)) {
        return {
          'status': 'error',
          'message': 'Invalid webhook signature',
        };
      }

      final event = requestBody;
      final eventType = event['type'];

      switch (eventType) {
        case 'payment_intent.succeeded':
          await _handlePaymentSuccess(event['data']['object']);
          break;
        case 'payment_intent.payment_failed':
          await _handlePaymentFailed(event['data']['object']);
          break;
        case 'payment_intent.requires_action':
          // Handle 3D Secure or other authentication
          await _handleAuthenticationRequired(event['data']['object']);
          break;
        default:
          print('Unhandled event type: $eventType');
      }

      return {
        'status': 'success',
        'received': true,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  static bool _verifySignature(
    Map<String, dynamic> payload,
    String signature,
  ) {
    // In production, use proper HMAC-SHA256 verification
    // This is a simplified verification for demo
    return signature.isNotEmpty;
  }

  static Future<void> _handlePaymentSuccess(dynamic paymentIntent) async {
    // Handle successful payment
    final String orderId = paymentIntent['metadata']?['order_id'] ?? '';
    final String paymentId = paymentIntent['id'];
    final double amount = paymentIntent['amount']?.toDouble() ?? 0.0;

    print('Payment succeeded for order: $orderId');
    print('Payment ID: $paymentId');
    print('Amount: \$${amount / 100}');

    // Update order status in Firestore
    await _updateOrderStatus(orderId, 'paid', paymentId);
  }

  static Future<void> _handlePaymentFailed(dynamic paymentIntent) async {
    // Handle failed payment
    final String orderId = paymentIntent['metadata']?['order_id'] ?? '';
    final String failureReason =
        paymentIntent['last_payment_error']?['message'] ?? 'Payment failed';

    print('Payment failed for order: $orderId');
    print('Reason: $failureReason');

    // Update order status in Firestore
    await _updateOrderStatus(orderId, 'failed', null, failureReason);
  }

  static Future<void> _handleAuthenticationRequired(
      dynamic paymentIntent) async {
    // Handle 3D Secure or other authentication
    print('Authentication required for payment intent: ${paymentIntent['id']}');
  }

  static Future<Map<String, dynamic>?> _updateOrderStatus(
    String orderId,
    String status,
    String? paymentId, [
    String? failureReason,
  ]) async {
    try {
      // This would typically be handled by your backend
      // For demo purposes, showing the structure
      final orderData = {
        'status': status,
        'payment_id': paymentId,
        'updated_at': DateTime.now().toIso8601String(),
        if (failureReason != null) 'failure_reason': failureReason,
      };

      print('Updating order $orderId with status: $status');
      return orderData;
    } catch (e) {
      print('Error updating order: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerEmail,
    required String orderId,
  }) async {
    final url = Uri.parse('https://api.stripe.com/v1/payment_intents');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': (amount * 100).toStringAsFixed(0), // Convert to cents
        'currency': currency,
        'receipt_email': customerEmail,
        'metadata[order_id]': orderId,
        'automatic_payment_methods[enabled]': 'true',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create payment intent: ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentId) async {
    final url = Uri.parse(
        'https://api.stripe.com/v1/payment_intents/$paymentIntentId/confirm');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $_stripeSecretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to confirm payment: ${response.body}');
    }
  }
}
