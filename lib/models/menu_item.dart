import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isSpicy;
  final bool isVegetarian;
  final bool inStock;
  final bool isRecommended;
  final bool hasOffer;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.isSpicy = false,
    this.isVegetarian = false,
    this.inStock = true,
    this.isRecommended = false,
    this.hasOffer = false,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isSpicy: json['isSpicy'] as bool,
      isVegetarian: json['isVegetarian'] as bool,
      inStock: json['inStock'] as bool? ?? true,
      isRecommended: json['isRecommended'] as bool? ?? false,
      hasOffer: json['hasOffer'] as bool? ?? false,
    );
  }

  factory MenuItem.fromFirestore(DocumentSnapshot doc) {
    return MenuItem.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  factory MenuItem.fromMap(String id, Map<String, dynamic> data) {
    return MenuItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? 'General',
      isSpicy: data['isSpicy'] ?? false,
      isVegetarian: data['isVegetarian'] ?? false,
      inStock: data['inStock'] ?? true,
      isRecommended: data['isRecommended'] ?? false,
      hasOffer: data['hasOffer'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isSpicy': isSpicy,
      'isVegetarian': isVegetarian,
      'inStock': inStock,
      'isRecommended': isRecommended,
      'hasOffer': hasOffer,
    };
  }

  static List<MenuItem> dummyItems = [
    // Starters
    MenuItem(
      id: '1',
      name: 'Veg  Samosa 333',
      description: 'Crispy pastry filled with spiced potatoes and peas',
      price: 8.99,
      imageUrl: 'assets/images/samosa.svg',
      category: 'Starters',
      isVegetarian: true,
      inStock: true,
    ),
    MenuItem(
      id: '2',
      name: 'Veg Manchurian',
      description: 'Indo-Chinese style vegetable dumplings in a spicy sauce',
      price: 14.99,
      imageUrl: 'assets/images/manchurian.svg',
      category: 'Starters',
      isVegetarian: true,
      isSpicy: true,
      inStock: true,
    ),

    // Main Course
    MenuItem(
      id: '3',
      name: 'Butter Chicken',
      description: 'Tender chicken pieces in a rich, creamy tomato sauce',
      price: 18.99,
      imageUrl: 'assets/images/butter_chicken.svg',
      category: 'Main Course',
      inStock: true,
    ),
    MenuItem(
      id: '4',
      name: 'Chicken Saag',
      description: 'Chicken cooked with fresh spinach and aromatic spices',
      price: 18.99,
      imageUrl: 'assets/images/chicken_saag.svg',
      category: 'Main Course',
      inStock: true,
    ),
    MenuItem(
      id: '5',
      name: 'Lamb Madras',
      description: 'Spicy lamb curry cooked with coconut and South Indian spices',
      price: 19.99,
      imageUrl: 'assets/images/lamb_madras.svg',
      category: 'Main Course',
      isSpicy: true,
      inStock: true,
    ),
    MenuItem(
      id: '6',
      name: 'Goat Vindaloo',
      description: 'Spicy goat curry with potatoes in a tangy sauce',
      price: 20.99,
      imageUrl: 'assets/images/goat_vindaloo.svg',
      category: 'Main Course',
      isSpicy: true,
      inStock: true,
    ),
    MenuItem(
      id: '7',
      name: 'Prawn Masala',
      description: 'Prawns cooked in a rich, spiced tomato-based sauce',
      price: 21.99,
      imageUrl: 'assets/images/prawn_masala.svg',
      category: 'Main Course',
      inStock: true,
    ),
    MenuItem(
      id: '8',
      name: 'Palak Paneer',
      description: 'Fresh cottage cheese cubes in a creamy spinach sauce',
      price: 17.99,
      imageUrl: 'assets/images/palak_paneer.svg',
      category: 'Main Course',
      isVegetarian: true,
      inStock: true,
    ),

    // Rice and Biryani
    MenuItem(
      id: '9',
      name: 'Steam Rice',
      description: 'Steamed basmati rice',
      price: 6.99,
      imageUrl: 'assets/images/steam_rice.svg',
      category: 'Rice',
      isVegetarian: true,
      inStock: true,
    ),
    MenuItem(
      id: '10',
      name: 'Veg Biryani',
      description: 'Fragrant basmati rice cooked with mixed vegetables, yoghurt, coriander & Indian spices',
      price: 14.99,
      imageUrl: 'assets/images/veg_biryani.svg',
      category: 'Rice',
      isVegetarian: true,
      isSpicy: true,
      inStock: true,
    ),
    MenuItem(
      id: '11',
      name: 'Chicken Biryani',
      description: 'Fragrant basmati rice cooked with tender chicken pieces, yoghurt, coriander & Indian spices',
      price: 15.99,
      imageUrl: 'assets/images/chicken_biryani.svg',
      category: 'Rice',
      isSpicy: true,
      inStock: true,
    ),

    // Breads
    MenuItem(
      id: '12',
      name: 'Plain Naan',
      description: 'Traditional Indian leavened bread baked in tandoor',
      price: 3.99,
      imageUrl: 'assets/images/plain_naan.svg',
      category: 'Breads',
      isVegetarian: true,
      inStock: true,
    ),
    MenuItem(
      id: '13',
      name: 'Butter Naan',
      description: 'Naan bread brushed with butter',
      price: 4.49,
      imageUrl: 'assets/images/butter_naan.svg',
      category: 'Breads',
      isVegetarian: true,
      inStock: true,
    ),
    MenuItem(
      id: '14',
      name: 'Garlic Naan',
      description: 'Naan bread topped with fresh garlic & herbs',
      price: 4.99,
      imageUrl: 'assets/images/garlic_naan.svg',
      category: 'Breads',
      isVegetarian: true,
      inStock: true,
    ),

    // Desserts
    MenuItem(
      id: '15',
      name: 'Gulab Jamun',
      description: 'Deep-fried milk dumplings soaked in sugar syrup',
      price: 6.99,
      imageUrl: 'assets/images/gulab_jamun.svg',
      category: 'Desserts',
      isVegetarian: true,
    ),
  ];
}