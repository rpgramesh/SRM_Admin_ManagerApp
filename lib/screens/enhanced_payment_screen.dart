import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
import '../providers/cart_provider.dart';
import '../theme/design_tokens.dart';
import '../models/cart_item.dart';

class EnhancedPaymentScreen extends StatefulWidget {
  const EnhancedPaymentScreen({super.key});

  @override
  State<EnhancedPaymentScreen> createState() => _EnhancedPaymentScreenState();
}

class _EnhancedPaymentScreenState extends State<EnhancedPaymentScreen> {
  // final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      // await StripeService.init();
      await _loadPaymentSheet();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize payment: ${e.toString()}';
      });
    }
  }

  Future<void> _loadPaymentSheet() async {
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);
      
      if (cart.items.isEmpty) {
        setState(() {
          _errorMessage = 'Cart is empty';
        });
        return;
      }

      // final result = await StripeService.initPaymentSheet(
      //   amount: cart.totalAmount,
      //   currency: 'USD',
      //   customerEmail: 'customer@example.com', // Update with actual customer email
      //   customerName: 'Customer Name', // Update with actual customer name
      // );
      
      // if (!result['success']) {
      //   throw Exception('Failed to initialize payment sheet');
      // }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payment sheet: ${e.toString()}';
      });
    }
  }

  Future<void> _handlePayment() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
        if (!kIsWeb) {
          // Mobile: Present native payment sheet
          // await Stripe.instance.presentPaymentSheet();
        } else {
          // Web platform - simulate payment for demo
          await Future.delayed(const Duration(seconds: 2));
          _showPaymentSuccess();
          return;
        }
        
        // final result = await StripeService.confirmPayment();
        
        // if (result['success'] == true && result['status'] == 'succeeded') {
        //   _showPaymentSuccess();
        // } else {
        //   // Handle desktop platform or failures
        //   setState(() {
        //     if (result['platform'] == 'desktop') {
        //       _errorMessage = 'Desktop platform detected. Payment processing simulated.';
        //     } else {
        //       _errorMessage = 'Payment failed: ${result['error'] ?? result['status']}';
        //     }
        //   });
        // }
      } 
    //   on StripeException catch (e) {
    //     setState(() {
    //       _errorMessage = 'Stripe error: ${e.error.localizedMessage}';
    //   });
    // } 
    catch (e) {
      setState(() {
        _errorMessage = 'Payment error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        title: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order has been placed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clear();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              ),
            ),
            child: const Text('Continue Shopping'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Continue Shopping'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderSummary(cart),
                const SizedBox(height: 24),
                _buildPaymentSection(cart),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _buildPaymentButton(cart),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final cartItem = cart.items.values.elementAt(index);
                return _buildCartItem(cartItem);
              },
            ),
            const SizedBox(height: 16),
            _buildTotalSection(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Row(
      children: [
        // Item image placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
            image: DecorationImage(
              image: NetworkImage(item.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              Text(
                'A\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'A\$${(item.price * item.quantity).toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Qty: ${item.quantity}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalSection(CartProvider cart) {
    final subtotal = cart.totalAmount;
    const taxRate = 0.08;
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return Column(
      children: [
        Divider(color: Colors.grey),
        const SizedBox(height: 12),
        _buildTotalRow('Subtotal', subtotal),
        _buildTotalRow('Tax (8%)', tax),
        _buildTotalRow('Total', total, isBold: true),
      ],
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            'A\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.green : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Secure payment with Stripe',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
                Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Pay A\$${cart.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}