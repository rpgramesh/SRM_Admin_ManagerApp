import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/enhanced_menu_item_card.dart';
import '../theme/design_tokens.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesProvider>(context, listen: false).loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text(
          'My Favorites',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: DesignTokens.neutralGrey900,
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, child) {
              if (favoritesProvider.favoriteCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showClearFavoritesDialog(context, favoritesProvider),
                  tooltip: 'Clear all favorites',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, favoritesProvider, child) {
          final favoriteItems = favoritesProvider.favoriteItems;
          
          if (favoriteItems.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              _buildHeader(favoritesProvider.favoriteCount),
              Expanded(
                child: _buildFavoritesList(favoriteItems),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildHeader(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: const BoxDecoration(
        color: DesignTokens.neutralWhite,
        border: Border(
          bottom: BorderSide(
            color: DesignTokens.neutralGrey200,
            width: 1,
          ),
        ),
      ),
      child: Text(
        '$count favorite${count == 1 ? '' : 's'}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: DesignTokens.neutralGrey700,
        ),
      ),
    );
  }
  
  Widget _buildFavoritesList(List favoriteItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(DesignTokens.space16),
      itemCount: favoriteItems.length,
      itemBuilder: (context, index) {
        final item = favoriteItems[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignTokens.space12),
          child: EnhancedMenuItemCard(
            item: item,
            onTap: () => _showItemDetails(context, item),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space24),
            decoration: BoxDecoration(
              color: DesignTokens.neutralGrey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 64,
              color: DesignTokens.neutralGrey400,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey700,
            ),
          ),
          const SizedBox(height: DesignTokens.space12),
          Text(
            'Start adding items to your favorites\nby tapping the heart icon on menu items',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: DesignTokens.neutralGrey500,
              height: 1.5,
            ),
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
                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
              ),
            ),
            child: const Text(
              'Browse Menu',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showItemDetails(BuildContext context, item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildItemDetailsSheet(item),
    );
  }
  
  Widget _buildItemDetailsSheet(item) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(DesignTokens.radiusXLarge),
          topRight: Radius.circular(DesignTokens.radiusXLarge),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: DesignTokens.space12),
            decoration: BoxDecoration(
              color: DesignTokens.neutralGrey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.neutralGrey900,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space8),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 16,
                      color: DesignTokens.primaryOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space16),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: DesignTokens.neutralGrey600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space24),
                  Row(
                    children: [
                      if (item.isVegetarian)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space12,
                            vertical: DesignTokens.space6,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.vegetarianGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco,
                                size: 16,
                                color: DesignTokens.vegetarianGreen,
                              ),
                              const SizedBox(width: DesignTokens.space4),
                              Text(
                                'Vegetarian',
                                style: TextStyle(
                                  color: DesignTokens.vegetarianGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (item.isVegetarian && item.isSpicy)
                        const SizedBox(width: DesignTokens.space8),
                      if (item.isSpicy)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space12,
                            vertical: DesignTokens.space6,
                          ),
                          decoration: BoxDecoration(
                            color: DesignTokens.spicyRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: 16,
                                color: DesignTokens.spicyRed,
                              ),
                              const SizedBox(width: DesignTokens.space4),
                              Text(
                                'Spicy',
                                style: TextStyle(
                                  color: DesignTokens.spicyRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        'A\$${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.primaryOrange,
                        ),
                      ),
                      const Spacer(),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          return ElevatedButton(
                            onPressed: () {
                              cart.addItem(item);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${item.name} added to cart'),
                                  backgroundColor: DesignTokens.primaryOrange,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: DesignTokens.primaryOrange,
                              foregroundColor: DesignTokens.neutralWhite,
                              padding: const EdgeInsets.symmetric(
                                horizontal: DesignTokens.space32,
                                vertical: DesignTokens.space16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                              ),
                            ),
                            child: const Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _showClearFavoritesDialog(BuildContext context, FavoritesProvider favoritesProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear All Favorites'),
          content: const Text('Are you sure you want to remove all items from your favorites?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                favoritesProvider.clearFavorites();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites cleared'),
                    backgroundColor: DesignTokens.primaryOrange,
                  ),
                );
              },
              child: const Text(
                'Clear All',
                style: TextStyle(color: DesignTokens.primaryRed),
              ),
            ),
          ],
        );
      },
    );
  }
}