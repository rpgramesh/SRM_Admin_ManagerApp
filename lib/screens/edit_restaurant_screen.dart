import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manager_service.dart';

class EditRestaurantScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;
  
  const EditRestaurantScreen({super.key, required this.restaurant});

  @override
  State<EditRestaurantScreen> createState() => _EditRestaurantScreenState();
}

class _EditRestaurantScreenState extends State<EditRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _cuisineController;
  late final TextEditingController _deliveryRadiusController;
  late final TextEditingController _minimumOrderController;
  late final TextEditingController _deliveryFeeController;
  late final TextEditingController _taxRateController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  late bool _isActive;
  late final List<String> _selectedPaymentMethods;
  final List<String> _paymentOptions = ['credit_card', 'cash', 'digital_wallet'];

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers with existing data
    _nameController = TextEditingController(text: widget.restaurant['name'] ?? '');
    _addressController = TextEditingController(text: widget.restaurant['address'] ?? '');
    _phoneController = TextEditingController(text: widget.restaurant['phone'] ?? '');
    _emailController = TextEditingController(text: widget.restaurant['email'] ?? '');
    _cuisineController = TextEditingController(text: widget.restaurant['cuisine_type'] ?? '');
    _deliveryRadiusController = TextEditingController(text: widget.restaurant['delivery_radius']?.toString() ?? '');
    _minimumOrderController = TextEditingController(text: widget.restaurant['minimum_order']?.toString() ?? '');
    _deliveryFeeController = TextEditingController(text: widget.restaurant['delivery_fee']?.toString() ?? '');
    _taxRateController = TextEditingController(text: widget.restaurant['tax_rate']?.toString() ?? '');
    
    final geoLocation = widget.restaurant['geoLocation'] as Map<String, dynamic>?;
    _latitudeController = TextEditingController(text: geoLocation?['latitude']?.toString() ?? '');
    _longitudeController = TextEditingController(text: geoLocation?['longitude']?.toString() ?? '');
    
    _isActive = widget.restaurant['isActive'] ?? true;
    _selectedPaymentMethods = List<String>.from(widget.restaurant['payment_methods'] ?? []);
  }

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
        title: const Text('Edit Restaurant'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // Toggle button for Open/Close status
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isActive ? 'Open' : 'Closed',
                  style: TextStyle(
                    color: _isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                    _updateRestaurantStatus(value);
                  },
                  activeThumbColor: Colors.green,
                  inactiveThumbColor: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateRestaurant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Update Restaurant',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  void _updateRestaurantStatus(bool isActive) async {
    try {
      await Provider.of<ManagerService>(context, listen: false)
          .updateRestaurantStatus(widget.restaurant['id'], isActive);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restaurant status updated to ${isActive ? "Open" : "Closed"}'),
          backgroundColor: isActive ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  void _updateRestaurant() async {
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
      };

      try {
        await Provider.of<ManagerService>(context, listen: false)
            .updateRestaurant(widget.restaurant['id'], restaurantData);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant updated successfully')),
        );
        
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating restaurant: $e')),
        );
      }
    }
  }
}