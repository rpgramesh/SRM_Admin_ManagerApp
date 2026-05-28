import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';
import 'package:uuid/uuid.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalAmount = cartProvider.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RadioListTile<String>(
              title: const Text('Credit/Debit Card'),
              value: 'card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Net Banking'),
              value: 'net_banking',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('UPI'),
              value: 'upi',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'cod',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 30),
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:', style: TextStyle(fontSize: 16)),
                Text('${cartProvider.itemCount}', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\$${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedPaymentMethod != null) {
                    // Get the current user from AuthProvider
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final user = authProvider.user;
                    
                    // Get FirestoreService instance
                                  final firestoreService = Provider.of<FirestoreService>(context, listen: false);
                                  
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Payment Confirmation'),
                                        content: Text('You have selected $_selectedPaymentMethod. Proceed with payment?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              // Show loading indicator
                                              Navigator.of(context).pop();
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  return const Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                },
                                              );
                                              
                                              try {
                                                // Create a new order
                                                final customerId = user?.uid ?? const Uuid().v4(); // Use actual user ID or generate one for demo
                                                final customerName = user?.displayName ?? 'Guest User';
                                                final customerAddress = '123 Main St, Melbourne'; // In a real app, get from user profile or input
                                                final customerPhone = '0412345678'; // In a real app, get from user profile or input
                                                
                                                // Create order data using proper Order model format
                                                final orderData = {
                                                  'customerId': customerId,
                                                  'customerName': customerName,
                                                  'customerAddress': customerAddress,
                                                  'customerPhone': customerPhone,
                                                  'items': cartProvider.items.values.map((item) => item.toJson()).toList(),
                                                  'totalAmount': cartProvider.totalAmount,
                                                  'status': 'pending', // This matches OrderStatus.pending enum
                                                  'paymentMethod': _selectedPaymentMethod,
                                                  'orderTime': FieldValue.serverTimestamp(),
                                                  'updatedAt': FieldValue.serverTimestamp(),
                                                };
                                                
                                                await firestoreService.createOrder(orderData);
                                  
                                  // Close loading indicator
                                Navigator.of(context).pop();
                                
                                // Clear the cart after successful order
                                cartProvider.clear();
                                
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Payment successful! Your order has been placed.'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                
                                // Navigate to payment success screen
                                Navigator.of(context).pushReplacementNamed('/payment_success');
                                } catch (e) {
                                  // Close loading indicator
                                  Navigator.of(context).pop();
                                  
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error placing order: ${e.toString()}')),
                                  );
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a payment method.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Proceed to Pay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}