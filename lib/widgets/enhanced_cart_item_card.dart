import 'package:flutter/material.dart';
//import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import '../theme/design_tokens.dart';

class EnhancedCartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const EnhancedCartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<EnhancedCartItemCard> createState() => _EnhancedCartItemCardState();
}

class _EnhancedCartItemCardState extends State<EnhancedCartItemCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeIn,
    ));
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _handleQuantityChange(int newQuantity) {
    if (newQuantity <= 0) {
      _removeItem();
    } else {
      widget.onQuantityChanged(newQuantity);
    }
  }

  void _removeItem() async {
    setState(() => _isRemoving = true);
    await _slideController.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_slideAnimation, _scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: DesignTokens.space4),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralBlack.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(widget.cartItem.id),
        direction: DismissDirection.endToStart,
        background: _buildDismissBackground(),
        onDismissed: (direction) => _removeItem(),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space16),
          child: Row(
            children: [
              _buildItemImage(),
              const SizedBox(width: DesignTokens.space16),
              Expanded(
                child: _buildItemDetails(),
              ),
              const SizedBox(width: DesignTokens.space12),
              _buildQuantityControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: DesignTokens.space20),
      decoration: BoxDecoration(
        color: DesignTokens.errorRed,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline,
            color: DesignTokens.neutralWhite,
            size: 24,
          ),
          SizedBox(height: DesignTokens.space4),
          Text(
            'Remove',
            style: TextStyle(
              color: DesignTokens.neutralWhite,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primaryOrange.withOpacity(0.3),
            DesignTokens.primaryRed.withOpacity(0.3),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: widget.cartItem.imageUrl.isNotEmpty
            ? Image.network(
                widget.cartItem.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignTokens.primaryOrange.withOpacity(0.5),
            DesignTokens.primaryRed.withOpacity(0.5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.restaurant_menu,
          size: 32,
          color: DesignTokens.neutralWhite,
        ),
      ),
    );
  }

  Widget _buildItemDetails() {
    final totalPrice = widget.cartItem.price * widget.cartItem.quantity;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.cartItem.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          widget.cartItem.category,
          style: const TextStyle(
            fontSize: 12,
            color: DesignTokens.neutralGrey500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DesignTokens.space8),
        Row(
          children: [
            Text(
              'A\$${widget.cartItem.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.primaryOrange,
              ),
            ),
            const Text(
              ' × ',
              style: TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey500,
              ),
            ),
            Text(
              '${widget.cartItem.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey700,
              ),
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          'A\$${totalPrice.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DesignTokens.neutralGrey900,
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.neutralGrey50,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
        border: Border.all(
          color: DesignTokens.neutralGrey200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => _handleQuantityChange(widget.cartItem.quantity + 1),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: DesignTokens.neutralGrey200),
                bottom: BorderSide(color: DesignTokens.neutralGrey200),
              ),
            ),
            child: Center(
              child: Text(
                '${widget.cartItem.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.neutralGrey900,
                ),
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => _handleQuantityChange(widget.cartItem.quantity - 1),
            isDecrease: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isDecrease = false,
  }) {
    return GestureDetector(
      onTapDown: (details) => _scaleController.forward(),
      onTapUp: (details) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      onTap: onPressed,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDecrease && widget.cartItem.quantity == 1
              ? DesignTokens.errorRed.withOpacity(0.1)
              : DesignTokens.neutralWhite,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        ),
        child: Center(
          child: Icon(
            isDecrease && widget.cartItem.quantity == 1 ? Icons.delete_outline : icon,
            size: 18,
            color: isDecrease && widget.cartItem.quantity == 1
                ? DesignTokens.errorRed
                : DesignTokens.primaryOrange,
          ),
        ),
      ),
    );
  }
}