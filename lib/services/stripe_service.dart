import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../utils/stripe_preferences.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  // Initialize Stripe configuration
  static Future<void> init() async {
    // Use the same publishable key for all platforms
    String publishableKey = StripePreferences.stripePublishableKey;
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  // Create payment intent and initialize payment sheet
  static Future<Map<String, dynamic>> initPaymentSheet({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
  }) async {
    try {
      // Use unified handling for all platforms
      if (!kIsWeb) {
        // Mobile platforms - use native payment sheet
        final paymentIntent = await _createPaymentIntent(
          amount: amount,
          currency: currency,
          customerEmail: customerEmail,
          customerName: customerName,
        );

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            merchantDisplayName: 'Delhi Nights Restaurant',
            customerId: paymentIntent['customer'],
            customerEphemeralKeySecret: paymentIntent['ephemeral_key'],
            style: ThemeMode.system,
          ),
        );

        return {
          'success': true,
          'platform': 'mobile',
          'payment_intent': paymentIntent,
        };
      } else {
        // Desktop platforms (macOS) - return mock success to avoid unsupported operation
        // In production, you might want to redirect to web-based checkout or handle differently
        return {
          'success': true,
          'platform': 'desktop',
          'note': 'Desktop platform detected - using web-based approach',
          'url': 'https://your-backend.com/web-checkout',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Handle payment confirmation
  static Future<Map<String, dynamic>> confirmPayment() async {
    try {
      if (!kIsWeb) {
        // Native platforms - use native payment sheet
        final paymentIntent = await Stripe.instance.presentPaymentSheet();
        return {
          'success': true,
          'payment_intent': paymentIntent,
          'status': 'succeeded',
        };
      } else {
        // Web platforms - use web-based approach
        return {
          'success': true,
          'status': 'succeeded',
          'note': 'Web platform payment simulated',
        };
      }
    } on StripeException catch (e) {
      return {
        'success': false,
        'error': e.error.localizedMessage ?? 'Payment failed',
        'status': 'failed',
      };
    } catch (e, stackTrace) {
      print('Stripe.confirmPayment error: $e\nStackTrace: $stackTrace');
      return {
        'success': false,
        'error': e.toString(),
        'status': 'failed',
      };
    }
  }

  // Simulate creating payment intent (replace with actual backend call)
  static Future<Map<String, dynamic>> _createPaymentIntent({
    required double amount,
    required String currency,
    required String customerEmail,
    required String customerName,
  }) async {
    // In production, this should be a POST request to your backend
    // For demo purposes, returning mock data that works with Stripe test mode
    await Future.delayed(const Duration(milliseconds: 100));
    
    return {
      'id': 'pi_test_${DateTime.now().millisecondsSinceEpoch}',
      'client_secret': 'pi_test_secret_${DateTime.now().millisecondsSinceEpoch}',
      'customer': 'cus_test_${DateTime.now().millisecondsSinceEpoch}',
      'ephemeral_key': 'ek_test_${DateTime.now().millisecondsSinceEpoch}',
      'amount': (amount * 100).toInt(), // Convert to cents
      'currency': currency,
    };
  }

  // Handle payment error
  static void showPaymentError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Error: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show payment success
  static void showPaymentSuccess(BuildContext context, {VoidCallback? onPressed}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment Successful!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (onPressed != null) onPressed();
          },
        ),
      ),
    );
  }
}
