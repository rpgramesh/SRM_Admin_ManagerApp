import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../theme/design_tokens.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import 'package:provider/provider.dart';

class EnhancedMenuItemCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback? onTap;

  const EnhancedMenuItemCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  State<EnhancedMenuItemCard> createState() => _EnhancedMenuItemCardState();
}

class _EnhancedMenuItemCardState extends State<EnhancedMenuItemCard>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: Container(
              margin: const EdgeInsets.all(DesignTokens.space8),
              decoration: BoxDecoration(
                color: DesignTokens.neutralWhite,
                borderRadius: BorderRadius.circular(DesignTokens.radiusXLarge),
                boxShadow: [
                  BoxShadow(
                    color: DesignTokens.neutralGrey900.withOpacity(0.1),
                    blurRadius: DesignTokens.elevationMedium,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  _buildContentSection(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DesignTokens.radiusXLarge),
            topRight: Radius.circular(DesignTokens.radiusXLarge),
          ),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DesignTokens.primaryOrange.withOpacity(0.3),
                  DesignTokens.primaryRed.withOpacity(0.3),
                ],
              ),
            ),
            child: widget.item.imageUrl.isNotEmpty
                ? Image.network(
                    widget.item.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
        ),
        _buildBadges(),
      ],
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
          size: 48,
          color: DesignTokens.neutralWhite,
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Positioned(
      top: DesignTokens.space12,
      right: DesignTokens.space12,
      child: Column(
        children: [
          _buildFavoriteButton(),
          if (widget.item.isVegetarian)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.space4),
              child: _buildBadge(
                icon: Icons.eco,
                color: DesignTokens.vegetarianGreen,
                tooltip: 'Vegetarian',
              ),
            ),
          if (widget.item.isSpicy)
            Padding(
              padding: const EdgeInsets.only(top: DesignTokens.space4),
              child: _buildBadge(
                icon: Icons.local_fire_department,
                color: DesignTokens.spicyRed,
                tooltip: 'Spicy',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final isFavorite = favoritesProvider.isFavorite(widget.item.id);
        
        return GestureDetector(
          onTap: () => favoritesProvider.toggleFavorite(widget.item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(DesignTokens.space8),
            decoration: BoxDecoration(
              color: isFavorite 
                  ? DesignTokens.primaryRed 
                  : DesignTokens.neutralWhite.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neutralBlack.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 16,
              color: isFavorite 
                  ? DesignTokens.neutralWhite 
                  : DesignTokens.neutralGrey600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required Color color,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.space8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: DesignTokens.neutralBlack.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: DesignTokens.neutralWhite,
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          const SizedBox(height: DesignTokens.space6),
          _buildDescription(),
          const SizedBox(height: DesignTokens.space12),
          _buildActionsRow(context),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space8,
            vertical: DesignTokens.space4,
          ),
          decoration: BoxDecoration(
            color: DesignTokens.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
          ),
          child: Text(
            widget.item.category,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: DesignTokens.primaryOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.item.description,
      style: const TextStyle(
        fontSize: 14,
        color: DesignTokens.neutralGrey600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      children: [
        Text(
          'A\$${widget.item.price.toStringAsFixed(0)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: DesignTokens.primaryOrange,
          ),
        ),
        const Spacer(),
        _buildAddToCartButton(context),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final quantity = cart.items[widget.item.id]?.quantity ?? 0;
        
        return AnimatedContainer(
          duration: DesignTokens.durationMedium,
          child: quantity == 0
              ? ElevatedButton(
                  onPressed: () => cart.addItem(widget.item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignTokens.primaryOrange,
                    foregroundColor: DesignTokens.neutralWhite,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space20,
                      vertical: DesignTokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                    ),
                    elevation: DesignTokens.elevationSmall,
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : _buildQuantityControls(context, cart, quantity),
        );
      },
    );
  }

  Widget _buildQuantityControls(BuildContext context, CartProvider cart, int quantity) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.primaryOrange,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantityButton(
            icon: Icons.remove,
            onPressed: () => cart.removeItem(widget.item.id),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.space16,
              vertical: DesignTokens.space8,
            ),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: DesignTokens.neutralWhite,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          _buildQuantityButton(
            icon: Icons.add,
            onPressed: () => cart.addItem(widget.item),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
        child: Container(
          padding: const EdgeInsets.all(DesignTokens.space8),
          child: Icon(
            icon,
            color: DesignTokens.neutralWhite,
            size: 18,
          ),
        ),
      ),
    );
  }
}