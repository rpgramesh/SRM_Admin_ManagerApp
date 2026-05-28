import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/manager_service.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _deliveryRadiusController = TextEditingController();
  final _minimumOrderController = TextEditingController();
  final _deliveryFeeController = TextEditingController();
  final _taxRateController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  bool _isActive = true;
  final List<String> _selectedPaymentMethods = [];
  final List<String> _paymentOptions = ['credit_card', 'cash', 'digital_wallet'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _cuisineController.dispose();
    _deliveryRadiusController.dispose();
    _minimumOrderController.dispose();
    _deliveryFeeController.dispose();
    _taxRateController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Restaurant'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Basic Information'),
              _buildTextField(
                controller: _nameController,
                label: 'Restaurant Name',
                icon: Icons.restaurant,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              _buildTextField(
                controller: _cuisineController,
                label: 'Cuisine Type',
                icon: Icons.local_dining,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Location Details'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latitudeController,
                      label: 'Latitude',
                      icon: Icons.my_location,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _longitudeController,
                      label: 'Longitude',
                      icon: Icons.my_location,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _deliveryRadiusController,
                label: 'Delivery Radius (km)',
                icon: Icons.location_on,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Pricing Settings'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _minimumOrderController,
                      label: 'Minimum Order',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _deliveryFeeController,
                      label: 'Delivery Fee',
                      icon: Icons.delivery_dining,
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _taxRateController,
                label: 'Tax Rate (decimal)',
                icon: Icons.receipt,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Payment Methods'),
              ..._paymentOptions.map((method) => CheckboxListTile(
                title: Text(method.replaceAll('_', ' ').toUpperCase()),
                value: _selectedPaymentMethods.contains(method),
                onChanged: (bool? value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedPaymentMethods.add(method);
                    } else {
                      _selectedPaymentMethods.remove(method);
                    }
                  });
                },
              )),
              
              const SizedBox(height: 20),
              _buildSectionHeader('Status'),
              SwitchListTile(
                title: const Text('Restaurant Active'),
                value: _isActive,
                onChanged: (bool value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeThumbColor: Colors.green,
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _addRestaurant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Add Restaurant',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.orange,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  void _addRestaurant() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedPaymentMethods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one payment method')),
        );
        return;
      }

      final restaurantData = {
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'cuisine_type': _cuisineController.text,
        'isActive': _isActive,
        'geoLocation': {
          'latitude': double.tryParse(_latitudeController.text) ?? 0.0,
          'longitude': double.tryParse(_longitudeController.text) ?? 0.0,
        },
        'delivery_radius': double.tryParse(_deliveryRadiusController.text) ?? 5.0,
        'minimum_order': double.tryParse(_minimumOrderController.text) ?? 15.0,
        'delivery_fee': double.tryParse(_deliveryFeeController.text) ?? 2.99,
        'tax_rate': double.tryParse(_taxRateController.text) ?? 0.0875,
        'payment_methods': _selectedPaymentMethods,
        'rating': 0.0,
        'total_reviews': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      try {
        await Provider.of<ManagerService>(context, listen: false)
            .addRestaurant(restaurantData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant added successfully')),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding restaurant: $e')),
        );
      }
    }
  }
}