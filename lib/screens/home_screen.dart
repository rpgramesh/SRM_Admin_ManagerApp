import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/category_chip.dart';
import '../services/firestore_service.dart';
import 'cart_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  int _selectedIndex = 0;
  late FirestoreService _firestoreService;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.add(_buildMenuScreen());
    _screens.add(const CartScreen());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _firestoreService = Provider.of<FirestoreService>(context);
  }

  final List<String> _categories = [
    'All',
    'Starters',
    'Main Course',
    'Breads',
    'Desserts',
  ];

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildMenuScreen() {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CategoryChip(
                  category: _categories[index],
                  isSelected: _selectedCategory == _categories[index],
                  onSelected: _onCategorySelected,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<MenuItem>>(
            stream: _firestoreService.getMenuItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No menu items found.'));
              }

              List<MenuItem> menuItems = snapshot.data!;
              List<MenuItem> filteredItems = menuItems.where((item) {
                if (_selectedCategory == 'All') {
                  return true;
                }
                return item.category == _selectedCategory;
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: MenuItemCard(menuItem: filteredItems[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/delhinightslogo.png',
          height: 100,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
      ),
    );
  }
}