class StripeWebhookService {
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
    throw UnsupportedError(
      'Create payment intents on your backend (never from a client app).',
    );
  }

  static Future<Map<String, dynamic>> confirmPayment(
      String paymentIntentId) async {
    throw UnsupportedError(
      'Confirm payments from your backend / Stripe SDK flow; not via secret keys in the client.',
    );
  }
}
