import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/design_tokens.dart';

extension DesignTokensExtension on DesignTokens {
  static double get borderRadius12 => 12.0;
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  // Mock data for saved payment methods
  List<Map<String, dynamic>> paymentMethods = [
    {
      'id': '1',
      'type': 'credit',
      'cardNumber': '**** **** **** 1234',
      'cardHolder': 'John Doe',
      'expiryDate': '12/25',
      'brand': 'Visa',
      'isDefault': true,
      'color': DesignTokens.primaryBlue,
    },
    {
      'id': '2',
      'type': 'credit',
      'cardNumber': '**** **** **** 5678',
      'cardHolder': 'John Doe',
      'expiryDate': '08/26',
      'brand': 'Mastercard',
      'isDefault': false,
      'color': DesignTokens.primaryOrange,
    },
    {
      'id': '3',
      'type': 'debit',
      'cardNumber': '**** **** **** 9012',
      'cardHolder': 'John Doe',
      'expiryDate': '03/27',
      'brand': 'American Express',
      'isDefault': false,
      'color': DesignTokens.primaryGreen,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralWhite,
      appBar: AppBar(
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: DesignTokens.neutralGrey900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Methods',
          style: TextStyle(
            color: DesignTokens.neutralGrey900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Payment Method Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: DesignTokens.space24),
              child: ElevatedButton.icon(
                onPressed: _showAddPaymentMethodDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primaryGreen,
                  foregroundColor: DesignTokens.neutralWhite,
                  padding: const EdgeInsets.symmetric(
                    vertical: DesignTokens.space16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Saved Payment Methods
            const Text(
              'Saved Payment Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey900,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),

            // Payment Methods List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paymentMethods.length,
              separatorBuilder: (context, index) => const SizedBox(height: DesignTokens.space12),
              itemBuilder: (context, index) {
                final method = paymentMethods[index];
                return _buildPaymentMethodCard(method, index);
              },
            ),

            const SizedBox(height: DesignTokens.space32),

            // Security Info
            Container(
              padding: const EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                color: DesignTokens.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                border: Border.all(
                  color: DesignTokens.info.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: DesignTokens.info,
                    size: 24,
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.info,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.space4),
                        Text(
                          'Your payment information is encrypted and secure. We never store your full card details.',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.neutralGrey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method, int index) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokensExtension.borderRadius12),
        border: Border.all(
          color: method['isDefault'] 
              ? DesignTokens.primaryGreen 
              : DesignTokens.neutralGrey200,
          width: method['isDefault'] ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey900.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Visual
          Container(
            height: 120,
            margin: const EdgeInsets.all(DesignTokens.space16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  method['color'],
                  method['color'].withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Card Brand
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        method['brand'],
                        style: const TextStyle(
                          color: DesignTokens.neutralWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (method['isDefault'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space8,
                            vertical: DesignTokens.space4,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.neutralWhite.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              color: DesignTokens.neutralWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  
                  // Card Number
                  Text(
                    method['cardNumber'],
                    style: const TextStyle(
                      color: DesignTokens.neutralWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  // Card Holder and Expiry
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        method['cardHolder'],
                        style: const TextStyle(
                          color: DesignTokens.neutralWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        method['expiryDate'],
                        style: const TextStyle(
                          color: DesignTokens.neutralWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(
              DesignTokens.space16,
              0,
              DesignTokens.space16,
              DesignTokens.space16,
            ),
            child: Row(
              children: [
                if (!method['isDefault'])
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _setAsDefault(index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.primaryGreen,
                        side: const BorderSide(color: DesignTokens.primaryGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        ),
                      ),
                      child: const Text(
                        'Set as Default',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                if (!method['isDefault'])
                  const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _editPaymentMethod(index),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: DesignTokens.neutralGrey600,
                        side: const BorderSide(color: DesignTokens.neutralGrey300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                        ),
                      ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                OutlinedButton(
                  onPressed: () => _deletePaymentMethod(index),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: DesignTokens.error,
                      side: const BorderSide(color: DesignTokens.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      ),
                    ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddPaymentMethodDialog() {
    final formKey = GlobalKey<FormState>();
    final cardNumberController = TextEditingController();
    final cardHolderController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Add Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Card Number
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  hintText: '1234 5678 9012 3456',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card number';
                  }
                  if (value.length < 16) {
                    return 'Card number must be 16 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.space16),
              
              // Card Holder
              TextFormField(
                controller: cardHolderController,
                decoration: const InputDecoration(
                  labelText: 'Card Holder Name',
                  hintText: 'John Doe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter card holder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: DesignTokens.space16),
              
              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Date',
                        hintText: 'MM/YY',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 4) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (value.length < 3) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _addPaymentMethod(
                  cardNumberController.text,
                  cardHolderController.text,
                  expiryController.text,
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primaryGreen,
              foregroundColor: DesignTokens.neutralWhite,
            ),
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }

  void _addPaymentMethod(String cardNumber, String cardHolder, String expiry) {
    final maskedNumber = '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    final formattedExpiry = '${expiry.substring(0, 2)}/${expiry.substring(2)}';
    
    setState(() {
      paymentMethods.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': 'credit',
        'cardNumber': maskedNumber,
        'cardHolder': cardHolder,
        'expiryDate': formattedExpiry,
        'brand': _detectCardBrand(cardNumber),
        'isDefault': paymentMethods.isEmpty,
        'color': _getCardColor(paymentMethods.length),
      });
    });
    
    _showSuccessMessage('Payment method added successfully!');
  }

  String _detectCardBrand(String cardNumber) {
    if (cardNumber.startsWith('4')) return 'Visa';
    if (cardNumber.startsWith('5')) return 'Mastercard';
    if (cardNumber.startsWith('3')) return 'American Express';
    return 'Unknown';
  }

  Color _getCardColor(int index) {
    final colors = [
      DesignTokens.primaryBlue,
      DesignTokens.primaryOrange,
      DesignTokens.primaryGreen,
      DesignTokens.primaryRed,
    ];
    return colors[index % colors.length];
  }

  void _setAsDefault(int index) {
    setState(() {
      for (int i = 0; i < paymentMethods.length; i++) {
        paymentMethods[i]['isDefault'] = i == index;
      }
    });
    _showSuccessMessage('Default payment method updated!');
  }

  void _editPaymentMethod(int index) {
    // For demo purposes, just show a message
    _showSuccessMessage('Edit functionality would be implemented here');
  }

  void _deletePaymentMethod(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final wasDefault = paymentMethods[index]['isDefault'];
                paymentMethods.removeAt(index);
                
                // If deleted card was default, set first card as default
                if (wasDefault && paymentMethods.isNotEmpty) {
                  paymentMethods[0]['isDefault'] = true;
                }
              });
              Navigator.pop(context);
              _showSuccessMessage('Payment method deleted successfully!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.error,
              foregroundColor: DesignTokens.neutralWhite,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: DesignTokens.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}