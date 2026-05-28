import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../theme/design_tokens.dart';
import '../widgets/enhanced_cart_item_card.dart';
// import '../services/stripe_service.dart'; // Removed for web compatibility
import '../services/firestore_service.dart';
import 'payment_success_screen.dart';

class EnhancedCartScreen extends StatefulWidget {
  const EnhancedCartScreen({super.key});

  @override
  State<EnhancedCartScreen> createState() => _EnhancedCartScreenState();
}

class _EnhancedCartScreenState extends State<EnhancedCartScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.itemCount == 0) {
          return _buildEmptyCart();
        }
        
        return Column(
          children: [
            _buildAppBar(cart),
            Expanded(
              child: _buildCartItems(cart),
            ),
            _buildBottomSection(cart),
          ],
        );
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space32),
            decoration: BoxDecoration(
              color: DesignTokens.primaryOrange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: DesignTokens.primaryOrange,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          const Text(
            'Add some delicious items to get started',
            style: TextStyle(
              fontSize: 16,
              color: DesignTokens.neutralGrey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.space32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryOrange,
              foregroundColor: DesignTokens.neutralWhite,
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space32,
                vertical: DesignTokens.space16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXLarge),
              ),
              elevation: DesignTokens.elevationMedium,
            ),
            child: const Text(
              'Browse Menu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(CartProvider cart) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + DesignTokens.space16,
        left: DesignTokens.space20,
        right: DesignTokens.space20,
        bottom: DesignTokens.space16,
      ),
      decoration: const BoxDecoration(
        color: DesignTokens.neutralWhite,
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.neutralGrey200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: DesignTokens.neutralGrey900,
            ),
          ),
          const Expanded(
            child: Text(
              'Your Cart',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: DesignTokens.neutralGrey900,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space12,
              vertical: DesignTokens.space8,
            ),
            decoration: BoxDecoration(
              color: DesignTokens.primaryOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
            ),
            child: Text(
              '${cart.itemCount} items',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(CartProvider cart) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: cart.items.length,
      itemBuilder: (context, index) {
        final cartItem = cart.items.values.toList()[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.space12),
          child: EnhancedCartItemCard(
            cartItem: cartItem,
            onQuantityChanged: (quantity) {
              if (quantity <= 0) {
                cart.removeItem(cartItem.id);
              } else {
                cart.updateQuantity(cartItem.id, quantity);
              }
            },
            onRemove: () => _showRemoveDialog(context, cart, cartItem),
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space20),
      decoration: const BoxDecoration(
        color: DesignTokens.neutralWhite,
        border: Border(
          top: BorderSide(
            color: DesignTokens.neutralGrey200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildOrderSummary(cart),
            const SizedBox(height: DesignTokens.space20),
            _buildCheckoutButton(cart),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart) {
    final subtotal = cart.totalAmount;
    final deliveryFee = subtotal > 500 ? 0.0 : 40.0;
    final taxes = subtotal * 0.18; // 18% GST
    final total = subtotal + deliveryFee + taxes;

    return Column(
      children: [
        _buildSummaryRow('Subtotal', 'A\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: DesignTokens.space8),
        _buildSummaryRow(
          'Delivery Fee', 
          deliveryFee == 0 ? 'FREE' : 'A\$${deliveryFee.toStringAsFixed(2)}',
          isDiscount: deliveryFee == 0,
        ),
        const SizedBox(height: DesignTokens.space8),
        _buildSummaryRow('Taxes & Fees', 'A\$${taxes.toStringAsFixed(2)}'),
        const Divider(height: DesignTokens.space20),
        _buildSummaryRow(
          'Total', 
          'A\$${total.toStringAsFixed(2)}',
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isDiscount ? DesignTokens.successGreen : 
                   isTotal ? DesignTokens.primaryOrange : DesignTokens.neutralGrey900,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigateToPayment(),
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primaryOrange,
          foregroundColor: DesignTokens.neutralWhite,
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
          ),
          elevation: DesignTokens.elevationMedium,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.payment,
              size: 20,
            ),
            const SizedBox(width: DesignTokens.space8),
            Text(
              'Proceed to Payment • A\$${(cart.totalAmount + (cart.totalAmount > 500 ? 0 : 40) + (cart.totalAmount * 0.18)).toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPayment() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Calculate total amount including delivery fee and taxes
      final subtotal = cart.totalAmount;
      final deliveryFee = subtotal > 500 ? 0.0 : 40.0;
      final taxes = subtotal * 0.18;
      final totalAmount = subtotal + deliveryFee + taxes;

      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Close loading dialog
      Navigator.of(context).pop();
      
      try {
        // Payment successful - create order in Firestore
        await _createOrder(cart, totalAmount);
        
        // Clear cart
        cart.clear();
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Your order has been placed.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentSuccessScreen(),
          ),
        );
      } catch (e) {
        // Payment failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createOrder(CartProvider cart, double totalAmount) async {
    final firestoreService = FirestoreService();
    
    // Create order data
    final orderData = {
      'customerId': 'customer_123', // You can get this from auth
      'customerName': 'Customer Name', // You can get this from user profile
      'customerAddress': '123 Main St, City', // You can get this from user profile
      'customerPhone': '+1234567890', // You can get this from user profile
      'items': cart.items.values.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': 'pending', // This matches OrderStatus.pending
      'paymentMethod': 'card',
      'orderTime': DateTime.now(),
      'updatedAt': DateTime.now(),
    };

    await firestoreService.createOrder(orderData);
  }

  void _showRemoveDialog(BuildContext context, CartProvider cart, CartItem cartItem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        ),
        title: const Text(
          'Remove Item',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${cartItem.title} from your cart?',
          style: const TextStyle(
            color: DesignTokens.neutralGrey600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: DesignTokens.neutralGrey600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              cart.removeItem(cartItem.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${cartItem.title} removed from cart'),
                  backgroundColor: DesignTokens.errorRed,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.errorRed,
              foregroundColor: DesignTokens.neutralWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}