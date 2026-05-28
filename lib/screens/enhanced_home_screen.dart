import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../widgets/enhanced_menu_item_card.dart';
import '../widgets/enhanced_category_chip.dart';
import '../theme/design_tokens.dart';
import '../providers/cart_provider.dart';
import '../services/firestore_service.dart';
import '../services/offer_service.dart'; // Add this import
import 'enhanced_cart_screen.dart';
import 'reserve_table_screen.dart';
import 'order_online_screen.dart';
import 'order_history_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../services/voice_order_service.dart';
import '../widgets/voice_listening_dialog.dart';
import 'package:restaurant_app/widgets/widgets_1/customNavBar.dart';

class EnhancedHomeScreen extends StatefulWidget {
  const EnhancedHomeScreen({super.key});

  @override
  State<EnhancedHomeScreen> createState() => _EnhancedHomeScreenState();
}

class _EnhancedHomeScreenState extends State<EnhancedHomeScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  final int _selectedIndex = 0;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Starters',
    'Main Course',
    'Breads',
    'Desserts',
  ];

  // Voice Order Service
  final VoiceOrderService _voiceOrderService = VoiceOrderService();
  bool _isVoiceServiceAvailable = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initVoiceService();
  }

  Future<void> _initVoiceService() async {
    try {
      bool available = await _voiceOrderService.init();
      if (mounted) {
        setState(() {
          _isVoiceServiceAvailable = available;
        });
      }
    } catch (e) {
      print('Voice service init error: $e');
    }
  }



  // Improved _handleVoiceOrder
  Future<void> _startVoiceOrdering() async {
      if (!_isVoiceServiceAvailable) return;

      final ValueNotifier<String> textNotifier = ValueNotifier<String>('');
      bool dialogOpen = true;
      
      // Show the dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return ValueListenableBuilder<String>(
            valueListenable: textNotifier,
            builder: (context, text, child) {
               return VoiceListeningDialog(
                 isListening: true,
                 text: text,
               );
            }
          );
        }
      ).then((_) {
          dialogOpen = false;
          _voiceOrderService.stopListening();
      });

      _voiceOrderService.startListening((text, isFinal) async {
         textNotifier.value = text;
         
         if (isFinal && text.isNotEmpty && dialogOpen) {
            Navigator.of(context, rootNavigator: true).pop(); // Close listening dialog
            
            // Show processing indicator
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing your order...'), duration: Duration(seconds: 1)),
              );
            }
            
            try {
               // Fetch menu items
               final firestoreService = Provider.of<FirestoreService>(context, listen: false);
               List<MenuItem> menuItems = await firestoreService.getMenuItemsOnce();
               
               // Process
               final cartProvider = Provider.of<CartProvider>(context, listen: false);
               if (!mounted) return;
               String result = _voiceOrderService.processCommand(text, menuItems, cartProvider);
               
               // Show result
               if (mounted) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Voice Order Result'),
                      content: Text(result.isEmpty ? 'No items matched.' : result),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                      ],
                    )
                  );
               }
            } catch (e) {
               if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error processing order: $e')),
                  );
               }
            }
         }
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Removed _filteredItems getter as we now use StreamBuilder with Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildAppBar(context),
          _buildQuickActions(),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMenuTab(),
            const ReserveTableScreen(),
            const OrderOnlineScreen(),
            _buildOffersTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomNavBar(),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      backgroundColor: DesignTokens.neutralWhite,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DesignTokens.primaryOrange.withAlpha((0.1 * 255).round()),
                DesignTokens.neutralWhite,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.space16,
                DesignTokens.space8,
                DesignTokens.space16,
                DesignTokens.space8,
              ),
              child: Row(
                children: [
                  // Restaurant Logo (Left)
                  SizedBox(
                    height: 40,
                    width: 60,
                    child: Image.asset(
                      'assets/images/delhinightslogo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space12),
                  // Search Bar (Center - Expanded)
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: DesignTokens.neutralGrey100,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search for dishes...',
                          prefixIcon: const Icon(Icons.search, color: DesignTokens.neutralGrey600, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: DesignTokens.neutralGrey600, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : IconButton(
                                  icon: Icon(
                                    Icons.mic,
                                    color: _isVoiceServiceAvailable ? DesignTokens.primaryOrange : DesignTokens.neutralGrey400,
                                    size: 20,
                                  ),
                                  onPressed: _isVoiceServiceAvailable ? _startVoiceOrdering : null,
                                  tooltip: 'Voice Order',
                                ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: DesignTokens.space12,
                            vertical: DesignTokens.space8,
                          ),
                          hintStyle: const TextStyle(fontSize: 14),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space8),
                  // Cart Button (Right)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, size: 24),
                        onPressed: () => _navigateToCart(),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) {
                          if (cart.itemCount == 0) return const SizedBox();
                          return Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: DesignTokens.errorRed,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                '${cart.itemCount}',
                                style: const TextStyle(
                                  color: DesignTokens.neutralWhite,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Favorites Button (Right)
                  IconButton(
                    icon: const Icon(Icons.favorite_outline, size: 24),
                    onPressed: () => Navigator.pushNamed(context, '/favoritesScreen'),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                  // Profile Button (Right)
                  IconButton(
                    icon: const Icon(Icons.person_outline, size: 24),
                    onPressed: () => _showProfileMenu(),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Search section is now integrated into the app bar
  // SliverPersistentHeader _buildSearchSection() {
  //   return SliverPersistentHeader(
  //     pinned: true,
  //     delegate: _SearchSectionDelegate(
  //       searchController: _searchController,
  //       searchQuery: _searchQuery,
  //       onSearchChanged: (value) => setState(() => _searchQuery = value),
  //       onClearSearch: () {
  //         _searchController.clear();
  //         setState(() => _searchQuery = '');
  //       },
  //     ),
  //   );
  // }

  SliverToBoxAdapter _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Container(
        color: DesignTokens.neutralWhite,
        child: Column(
          children: [
            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: DesignTokens.primaryOrange,
              unselectedLabelColor: DesignTokens.neutralGrey600,
              indicatorColor: DesignTokens.primaryOrange,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Menu'),
                Tab(text: 'Reserve'),
                Tab(text: 'Delivery'),
                Tab(text: 'Offers'),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab() {
    final firestoreService = FirestoreService();
    final offerService = OfferService();
    
    return Column(
      children: [
        // Category Chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: DesignTokens.space8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: DesignTokens.space8),
                child: EnhancedCategoryChip(
                  label: category,
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                ),
              );
            },
          ),
        ),
        // Offers Section
        StreamBuilder<List<MenuItem>>(
          stream: offerService.getOfferItems(),
          builder: (context, offerSnapshot) {
            if (offerSnapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox.shrink();
            }
            
            final offerItems = offerSnapshot.data ?? [];
            
            if (offerItems.isEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Offers Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space16,
                    vertical: DesignTokens.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Special Offers',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey900,
                        ),
                      ),
                      if (offerItems.length > 3)
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/offerScreen'),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: DesignTokens.primaryOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Horizontal Offers List
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(bottom: DesignTokens.space16),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                    itemCount: offerItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: DesignTokens.space12),
                        child: _buildCompactOfferCard(offerItems[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        // Menu Items
        Expanded(
          child: StreamBuilder<List<MenuItem>>(
            stream: firestoreService.getMenuItems(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final menuItems = snapshot.data ?? [];
              
              // Apply filtering
              List<MenuItem> filteredItems = menuItems;
              
              // Filter by category
              if (_selectedCategory != 'All') {
                filteredItems = filteredItems.where((item) => 
                  item.category == _selectedCategory).toList();
              }
              
              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                filteredItems = filteredItems.where((item) => 
                  item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  item.description.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();
              }
              
              if (filteredItems.isEmpty) {
                return _buildEmptyState();
              }

              return GridView.builder(
                padding: const EdgeInsets.all(DesignTokens.space16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: DesignTokens.space12,
                  mainAxisSpacing: DesignTokens.space12,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return EnhancedMenuItemCard(item: filteredItems[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: DesignTokens.neutralGrey400,
          ),
          const SizedBox(height: DesignTokens.space16),
          Text(
            'No dishes found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.neutralGrey700,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            'Try adjusting your search or category filter',
            style: TextStyle(
              color: DesignTokens.neutralGrey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOffersTab() {
    final offerService = OfferService();
    
    return StreamBuilder<List<MenuItem>>(
      stream: offerService.getOfferItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        
        final offerItems = snapshot.data ?? [];
        
        if (offerItems.isEmpty) {
          return const Center(
            child: Text(
              'No special offers available right now!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: DesignTokens.neutralGrey700,
              ),
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Promotional Banner
            Container(
              margin: const EdgeInsets.all(DesignTokens.space16),
              padding: const EdgeInsets.all(DesignTokens.space16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [DesignTokens.primaryOrange, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Special Offers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${offerItems.length} items on offer',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/offerScreen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: DesignTokens.primaryOrange,
                    ),
                    child: const Text('View All'),
                  ),
                ],
              ),
            ),
            
            // Offer Items List
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: DesignTokens.space12,
                  mainAxisSpacing: DesignTokens.space12,
                ),
                itemCount: offerItems.length,
                itemBuilder: (context, index) {
                  return EnhancedMenuItemCard(item: offerItems[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildOfferItemCard(MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    ),
            ),
            const SizedBox(width: 12),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'OFFER',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.primaryOrange,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) => ElevatedButton(
                          onPressed: () => cart.addItem(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DesignTokens.primaryOrange,
                            minimumSize: const Size(80, 32),
                          ),
                          child: const Text('Add', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNavBar() {
    return const CustomNavBar(home: true, menu: false, offer: false, profile: false, more: false);
  }

  void _navigateToCart() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EnhancedCartScreen()),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: DesignTokens.neutralWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(DesignTokens.radiusLarge),
                  topRight: Radius.circular(DesignTokens.radiusLarge),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.space16),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: DesignTokens.neutralGrey300,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusSmall),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 160),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(DesignTokens.space24),
                    child: Text(
                      'Profile Menu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('My Profile'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Order History'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.track_changes),
                    title: const Text('Track Current Order'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToCurrentOrder();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.notifications_outlined),
                    title: const Text('Notifications'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToNotifications();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Settings'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to settings screen
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Implement logout
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToCurrentOrder() {
    // TODO: Check for active orders and navigate to tracking screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order tracking feature coming soon'),
      ),
    );
  }

  void _navigateToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationsScreen(),
      ),
    );
  }

  Widget _buildCompactOfferCard(MenuItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Image
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(DesignTokens.radiusMedium),
                topRight: Radius.circular(DesignTokens.radiusMedium),
              ),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: DesignTokens.neutralGrey200,
                        child: const Icon(
                          Icons.image_not_supported,
                          color: DesignTokens.neutralGrey500,
                        ),
                      ),
                    )
                  : Container(
                      color: DesignTokens.neutralGrey200,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: DesignTokens.neutralGrey500,
                      ),
                    ),
            ),
          ),
          // Item Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.space8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Item Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.neutralGrey900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Price and Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'A\$${item.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.primaryOrange,
                        ),
                      ),
                      Consumer<CartProvider>(
                        builder: (context, cart, child) => GestureDetector(
                          onTap: () => cart.addItem(item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: DesignTokens.primaryOrange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Add',
                              style: TextStyle(
                                color: DesignTokens.neutralWhite,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
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
}

// _SearchSectionDelegate is no longer needed as search is integrated into the app bar
// class _SearchSectionDelegate extends SliverPersistentHeaderDelegate {
//   final TextEditingController searchController;
//   final String searchQuery;
//   final Function(String) onSearchChanged;
//   final VoidCallback onClearSearch;
//
//   _SearchSectionDelegate({
//     required this.searchController,
//     required this.searchQuery,
//     required this.onSearchChanged,
//     required this.onClearSearch,
//   });
//
//   @override
//   double get minExtent => 60.0;
//
//   @override
//   double get maxExtent => 60.0;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return Container(
//       color: DesignTokens.neutralWhite,
//       padding: const EdgeInsets.fromLTRB(
//         DesignTokens.space16,
//         DesignTokens.space4,
//         DesignTokens.space16,
//         DesignTokens.space8,
//       ),
//       child: Container(
//         decoration: BoxDecoration(
//           color: DesignTokens.neutralGrey100,
//           borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
//         ),
//         child: TextField(
//           controller: searchController,
//           onChanged: onSearchChanged,
//           decoration: InputDecoration(
//             hintText: 'Search for dishes...',
//             prefixIcon: const Icon(Icons.search, color: DesignTokens.neutralGrey600),
//             suffixIcon: searchQuery.isNotEmpty
//                 ? IconButton(
//                     icon: const Icon(Icons.clear, color: DesignTokens.neutralGrey600),
//                     onPressed: onClearSearch,
//                   )
//                 : null,
//             border: InputBorder.none,
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: DesignTokens.space16,
//               vertical: DesignTokens.space8,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
//     return oldDelegate != this;
//   }
// }