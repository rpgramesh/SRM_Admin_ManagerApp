import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class EnhancedCategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? customColor;

  const EnhancedCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.customColor,
  });

  @override
  State<EnhancedCategoryChip> createState() => _EnhancedCategoryChipState();
}

class _EnhancedCategoryChipState extends State<EnhancedCategoryChip>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _selectionController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _selectionAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: DesignTokens.durationFast,
      vsync: this,
    );
    
    _selectionController = AnimationController(
      duration: DesignTokens.durationMedium,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _selectionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: DesignTokens.neutralGrey200,
      end: widget.customColor ?? DesignTokens.primaryOrange,
    ).animate(CurvedAnimation(
      parent: _selectionController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isSelected) {
      _selectionController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(EnhancedCategoryChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _selectionController.forward();
      } else {
        _selectionController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _selectionController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _selectionAnimation, _colorAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space20,
                vertical: DesignTokens.space12,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(DesignTokens.radiusXXLarge),
                border: Border.all(
                  color: _getBorderColor(),
                  width: 1.5,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: (_colorAnimation.value ?? DesignTokens.primaryOrange)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon!,
                      size: 18,
                      color: _getTextColor(),
                    ),
                    const SizedBox(width: DesignTokens.space8),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: _getTextColor(),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) {
      return _colorAnimation.value ?? DesignTokens.primaryOrange;
    }
    return DesignTokens.neutralWhite;
  }

  Color _getBorderColor() {
    if (widget.isSelected) {
      return _colorAnimation.value ?? DesignTokens.primaryOrange;
    }
    return DesignTokens.neutralGrey300;
  }

  Color _getTextColor() {
    if (widget.isSelected) {
      return DesignTokens.neutralWhite;
    }
    return DesignTokens.neutralGrey700;
  }
}

// Predefined category chips for common food categories
class FoodCategoryChips {
  static const Map<String, IconData> categoryIcons = {
    'All': Icons.restaurant_menu,
    'Appetizers': Icons.local_dining,
    'Main Course': Icons.dinner_dining,
    'Desserts': Icons.cake,
    'Beverages': Icons.local_cafe,
    'Snacks': Icons.fastfood,
    'Vegetarian': Icons.eco,
    'Non-Vegetarian': Icons.restaurant,
    'Spicy': Icons.local_fire_department,
    'Popular': Icons.star,
    'New': Icons.fiber_new,
    'Healthy': Icons.health_and_safety,
  };

  static const Map<String, Color> categoryColors = {
    'All': DesignTokens.neutralGrey600,
    'Appetizers': DesignTokens.primaryOrange,
    'Main Course': DesignTokens.primaryRed,
    'Desserts': DesignTokens.secondaryGold,
    'Beverages': DesignTokens.infoBlue,
    'Snacks': DesignTokens.accentSpice,
    'Vegetarian': DesignTokens.vegetarianGreen,
    'Non-Vegetarian': DesignTokens.nonVegBrown,
    'Spicy': DesignTokens.spicyRed,
    'Popular': DesignTokens.warningAmber,
    'New': DesignTokens.successGreen,
    'Healthy': DesignTokens.vegetarianGreen,
  };

  static EnhancedCategoryChip buildChip({
    required String category,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return EnhancedCategoryChip(
      label: category,
      isSelected: isSelected,
      onTap: onTap,
      icon: categoryIcons[category],
      customColor: categoryColors[category],
    );
  }
}