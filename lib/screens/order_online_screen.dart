import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/design_tokens.dart';
import '../providers/cart_provider.dart';
import '../models/menu_item.dart';
import '../widgets/enhanced_menu_item_card.dart';
import 'enhanced_cart_screen.dart';

class OrderOnlineScreen extends StatefulWidget {
  const OrderOnlineScreen({super.key});

  @override
  State<OrderOnlineScreen> createState() => _OrderOnlineScreenState();
}

class _OrderOnlineScreenState extends State<OrderOnlineScreen> {
  String _selectedDeliveryType = 'delivery';
  String _deliveryAddress = '';
  final TextEditingController _addressController = TextEditingController();
  String _selectedAddressType = 'Home';

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeliveryOptions(),
            const SizedBox(height: DesignTokens.space24),
            _buildAddressSection(),
            const SizedBox(height: DesignTokens.space24),
            _buildEstimatedTime(),
            const SizedBox(height: DesignTokens.space24),
            _buildPopularItems(),
            const SizedBox(height: DesignTokens.space24),
            _buildCartSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryOptions() {
    return Card(
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Delivery Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey800,
              ),
            ),
            const SizedBox(height: DesignTokens.space16),
            Row(
              children: [
                Expanded(
                  child: _DeliveryOptionCard(
                    icon: Icons.delivery_dining,
                    title: 'Delivery',
                    subtitle: '30-45 mins',
                    isSelected: _selectedDeliveryType == 'delivery',
                    onTap: () => setState(() => _selectedDeliveryType = 'delivery'),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: _DeliveryOptionCard(
                    icon: Icons.storefront,
                    title: 'Pickup',
                    subtitle: '15-20 mins',
                    isSelected: _selectedDeliveryType == 'pickup',
                    onTap: () => setState(() => _selectedDeliveryType = 'pickup'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
    if (_selectedDeliveryType == 'pickup') return const SizedBox();
    
    return Card(
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: DesignTokens.primaryOrange,
                  size: 20,
                ),
                const SizedBox(width: DesignTokens.space8),
                const Text(
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
            TextField(
              controller: _addressController,
              onChanged: (value) => setState(() => _deliveryAddress = value),
              decoration: InputDecoration(
                hintText: 'Enter your complete address...',
                prefixIcon: const Icon(Icons.home_outlined),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                  borderSide: const BorderSide(color: DesignTokens.primaryOrange),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: DesignTokens.space12),
            const Text(
              'Address Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DesignTokens.neutralGrey700,
              ),
            ),
            const SizedBox(height: DesignTokens.space8),
            Row(
              children: [
                _AddressTypeChip(
                  label: 'Home',
                  isSelected: _selectedAddressType == 'Home',
                  onTap: () => _selectAddressType('Home'),
                ),
                const SizedBox(width: DesignTokens.space8),
                _AddressTypeChip(
                  label: 'Work',
                  isSelected: _selectedAddressType == 'Work',
                  onTap: () => _selectAddressType('Work'),
                ),
                const SizedBox(width: DesignTokens.space8),
                _AddressTypeChip(
                  label: 'Other',
                  isSelected: _selectedAddressType == 'Other',
                  onTap: () => _selectAddressType('Other'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedTime() {
    return Card(
      elevation: DesignTokens.elevationSmall,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: DesignTokens.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
              ),
              child: const Icon(
                Icons.schedule,
                color: DesignTokens.primaryOrange,
                size: 20,
              ),
            ),
            const SizedBox(width: DesignTokens.space12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Time',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.neutralGrey600,
                  ),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  _selectedDeliveryType == 'delivery' ? '30-45 minutes' : '15-20 minutes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularItems() {
    final popularItems = [
      MenuItem(
        id: '1',
        name: 'Butter Chicken',
        description: 'Creamy tomato curry with tender chicken',
        price: 425.0,
        imageUrl: 'assets/images/butter_chicken.svg',
        category: 'Main Course',
        isVegetarian: false,
        isSpicy: true,
      ),
      MenuItem(
        id: '2',
        name: 'Paneer Tikka',
        description: 'Grilled cottage cheese with spices',
        price: 325.0,
        imageUrl: 'assets/images/paneer_tikka.svg',
        category: 'Appetizer',
        isVegetarian: true,
        isSpicy: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Items',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey800,
          ),
        ),
        const SizedBox(height: DesignTokens.space12),
        ...popularItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: DesignTokens.space12),
            child: EnhancedMenuItemCard(item: item),
          ),
        ),
      ],
    );
  }

  Widget _buildCartSummary() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) {
          return const SizedBox();
        }

        return Card(
          elevation: DesignTokens.elevationMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey800,
                  ),
                ),
                const SizedBox(height: DesignTokens.space12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${cart.totalItems} items',
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.neutralGrey600,
                      ),
                    ),
                    Text(
                      'A\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                  ],
                ),
                if (_selectedDeliveryType == 'delivery') ...[
                  const SizedBox(height: DesignTokens.space4),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee:',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey600,
                        ),
                      ),
                      Text(
                        'A\$50.00',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignTokens.neutralGrey800,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: DesignTokens.space8),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.neutralGrey800,
                      ),
                    ),
                    Text(
                      'A\$${(_selectedDeliveryType == 'delivery' ? cart.totalAmount + 50 : cart.totalAmount).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceedToCheckout() ? _proceedToCheckout : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignTokens.primaryOrange,
                      foregroundColor: DesignTokens.neutralWhite,
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.space16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _canProceedToCheckout() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) return false;
    if (_selectedDeliveryType == 'delivery' && _deliveryAddress.trim().isEmpty) return false;
    return true;
  }

  void _proceedToCheckout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EnhancedCartScreen(),
      ),
    );
  }

  void _getCurrentLocation() {
    _addressController.text = '123 Main Street, Mumbai, Maharashtra 400001';
    setState(() => _deliveryAddress = _addressController.text);
  }

  void _selectAddressType(String type) {
    setState(() => _selectedAddressType = type);
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  const _DeliveryOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(DesignTokens.space16),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primaryOrange.withOpacity(0.1) : DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          border: Border.all(
            color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey600,
              size: 32,
            ),
            const SizedBox(height: DesignTokens.space8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey800,
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: DesignTokens.neutralGrey600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTypeChip extends StatelessWidget {
  const _AddressTypeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.space12,
          vertical: DesignTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? DesignTokens.primaryOrange.withOpacity(0.1) : DesignTokens.neutralGrey100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          border: Border.all(
            color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey700,
          ),
        ),
      ),
    );
  }
}