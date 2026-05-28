import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_app/screens/screens_1/dessertScreen.dart';
import 'package:restaurant_app/utils/helper.dart';

class MenuScreen extends StatefulWidget {
  static const routeName = "/menuScreen";

  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        border: null,
        middle: Text(
          'Menu',
          style: CupertinoTheme.of(context)
              .textTheme
              .navLargeTitleTextStyle
              .copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Cart action
          },
          child: Icon(
            CupertinoIcons.cart,
            color: CupertinoColors.systemOrange,
            size: 28,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search Section
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search for dishes...',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                placeholderStyle:
                    CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                          color: CupertinoColors.placeholderText,
                        ),
                backgroundColor: CupertinoColors.tertiarySystemFill,
                borderRadius: BorderRadius.circular(12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),

            // Tab Bar Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: CupertinoSlidingSegmentedControl<int>(
                backgroundColor: CupertinoColors.tertiarySystemFill,
                thumbColor: CupertinoColors.systemBackground,
                groupValue: 0,
                children: const {
                  0: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Menu', style: TextStyle(fontSize: 16)),
                  ),
                  1: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Reserve', style: TextStyle(fontSize: 16)),
                  ),
                  2: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Delivery', style: TextStyle(fontSize: 16)),
                  ),
                  3: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Offers', style: TextStyle(fontSize: 16)),
                  ),
                },
                onValueChanged: (value) {
                  // Handle tab change
                },
              ),
            ),

            // Category Pills
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill('All', true),
                    _buildCategoryPill('Starters', false),
                    _buildCategoryPill('Main Course', false),
                    _buildCategoryPill('Breads', false),
                    _buildCategoryPill('Desserts', false),
                  ],
                ),
              ),
            ),

            // Menu Items List
            Expanded(
              child: CupertinoScrollbar(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildModernMenuCard(
                      context,
                      name: 'Food',
                      count: '120',
                      imagePath: Helper.getAssetName('western2.jpg', 'real'),
                      color: CupertinoColors.systemBlue,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildModernMenuCard(
                      context,
                      name: 'Beverage',
                      count: '220',
                      imagePath: Helper.getAssetName('coffee2.jpg', 'real'),
                      color: CupertinoColors.systemGreen,
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    _buildModernMenuCard(
                      context,
                      name: 'Desserts',
                      count: '135',
                      imagePath: Helper.getAssetName('dessert.jpg', 'real'),
                      color: CupertinoColors.systemPink,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(DessertScreen.routeName);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildModernMenuCard(
                      context,
                      name: 'Promotions',
                      count: '25',
                      imagePath: Helper.getAssetName('hamburger3.jpg', 'real'),
                      color: CupertinoColors.systemOrange,
                      onTap: () {},
                    ),
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        color: isSelected
            ? CupertinoColors.systemOrange
            : CupertinoColors.tertiarySystemFill,
        borderRadius: BorderRadius.circular(20),
        onPressed: () {
          // Handle category selection
        }, minimumSize: Size(0, 0),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? CupertinoColors.white : CupertinoColors.label,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildModernMenuCard(
    BuildContext context, {
    required String name,
    required String count,
    required String imagePath,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background Image
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      CupertinoColors.black.withOpacity(0.3),
                      BlendMode.darken,
                    ),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      color.withOpacity(0.8),
                      color.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle
                          .copyWith(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count items',
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .textStyle
                          .copyWith(
                            color: CupertinoColors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: CupertinoColors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      CupertinoIcons.chevron_right,
                      color: CupertinoColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Remove the old MenuCard class and custom clippers as they're no longer needed
