import 'package:flutter/material.dart';
import '../config/design_tokens.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedFilter = 'All';
  
  final List<String> filterOptions = ['All', '5 Stars', '4 Stars', '3 Stars', '2 Stars', '1 Star'];
  
  final List<Map<String, dynamic>> userReviews = [
    {
      'id': '1',
      'restaurantName': 'Spice Garden',
      'restaurantImage': 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      'rating': 5,
      'reviewText': 'Amazing food and excellent service! The biryani was perfectly cooked and the staff was very friendly. Definitely coming back again.',
      'date': '15 Dec 2024',
      'orderItems': ['Chicken Biryani', 'Mutton Curry', 'Naan'],
      'orderValue': 850,
      'helpful': 12,
      'restaurantReply': 'Thank you for your wonderful review! We\'re delighted you enjoyed your meal.',
      'images': [],
    },
    {
      'id': '2',
      'restaurantName': 'Pizza Corner',
      'restaurantImage': 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=400',
      'rating': 4,
      'reviewText': 'Good pizza with fresh toppings. The delivery was quick and the food arrived hot. Could use a bit more cheese though.',
      'date': '12 Dec 2024',
      'orderItems': ['Margherita Pizza', 'Garlic Bread'],
      'orderValue': 650,
      'helpful': 8,
      'restaurantReply': null,
      'images': [],
    },
    {
      'id': '3',
      'restaurantName': 'Burger House',
      'restaurantImage': 'https://images.unsplash.com/photo-1571091718767-18b5b1457add?w=400',
      'rating': 3,
      'reviewText': 'Average burger, nothing special. The fries were cold and the burger was a bit dry. Service was okay.',
      'date': '10 Dec 2024',
      'orderItems': ['Classic Burger', 'French Fries', 'Coke'],
      'orderValue': 450,
      'helpful': 3,
      'restaurantReply': 'We apologize for the experience. We\'ll work on improving our food quality.',
      'images': [],
    },
    {
      'id': '4',
      'restaurantName': 'Sushi Express',
      'restaurantImage': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
      'rating': 5,
      'reviewText': 'Fresh sushi and great presentation! The salmon was incredibly fresh and the rice was perfectly seasoned. Highly recommended!',
      'date': '8 Dec 2024',
      'orderItems': ['Salmon Roll', 'Tuna Sashimi', 'Miso Soup'],
      'orderValue': 1200,
      'helpful': 15,
      'restaurantReply': 'Thank you! We take pride in our fresh ingredients.',
      'images': [],
    },
    {
      'id': '5',
      'restaurantName': 'Cafe Mocha',
      'restaurantImage': 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=400',
      'rating': 2,
      'reviewText': 'Coffee was bitter and the pastry was stale. Not worth the price. The ambiance was nice but the food quality was disappointing.',
      'date': '5 Dec 2024',
      'orderItems': ['Cappuccino', 'Chocolate Croissant'],
      'orderValue': 320,
      'helpful': 5,
      'restaurantReply': null,
      'images': [],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredReviews {
    if (selectedFilter == 'All') {
      return userReviews;
    }
    
    int targetRating = int.parse(selectedFilter.split(' ')[0]);
    return userReviews.where((review) => review['rating'] == targetRating).toList();
  }

  double get averageRating {
    if (userReviews.isEmpty) return 0.0;
    double total = userReviews.fold(0.0, (sum, review) => sum + review['rating']);
    return total / userReviews.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.neutralGrey50,
      appBar: AppBar(
        title: const Text(
          'My Reviews',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: DesignTokens.neutralGrey900,
          ),
        ),
        backgroundColor: DesignTokens.neutralWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: DesignTokens.neutralGrey900),
        bottom: TabBar(
          controller: _tabController,
          labelColor: DesignTokens.primaryOrange,
          unselectedLabelColor: DesignTokens.neutralGrey600,
          indicatorColor: DesignTokens.primaryOrange,
          tabs: const [
            Tab(text: 'My Reviews'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReviewsTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        // Filter Section
        Container(
          margin: const EdgeInsets.all(DesignTokens.space16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filterOptions.map((filter) {
                final bool isSelected = selectedFilter == filter;
                return Container(
                  margin: const EdgeInsets.only(right: DesignTokens.space8),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? DesignTokens.neutralWhite : DesignTokens.neutralGrey700,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = filter;
                      });
                    },
                    backgroundColor: DesignTokens.neutralWhite,
                    selectedColor: DesignTokens.primaryOrange,
                    checkmarkColor: DesignTokens.neutralWhite,
                    side: BorderSide(
                      color: isSelected ? DesignTokens.primaryOrange : DesignTokens.neutralGrey300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        
        // Reviews List
        Expanded(
          child: filteredReviews.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space16),
                  itemCount: filteredReviews.length,
                  itemBuilder: (context, index) {
                    return _buildReviewCard(filteredReviews[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    final Map<int, int> ratingCounts = {};
    for (int i = 1; i <= 5; i++) {
      ratingCounts[i] = userReviews.where((review) => review['rating'] == i).length;
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Column(
        children: [
          // Overall Stats Card
          Container(
            padding: const EdgeInsets.all(DesignTokens.space20),
            decoration: BoxDecoration(
              color: DesignTokens.neutralWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neutralGrey200.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Your Review Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        title: 'Total Reviews',
                        value: userReviews.length.toString(),
                        icon: Icons.rate_review,
                        color: DesignTokens.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space16),
                    Expanded(
                      child: _buildStatItem(
                        title: 'Average Rating',
                        value: averageRating.toStringAsFixed(1),
                        icon: Icons.star,
                        color: DesignTokens.primaryOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        title: 'Helpful Votes',
                        value: userReviews.fold(0, (sum, review) => sum + (review['helpful'] as int)).toString(),
                        icon: Icons.thumb_up,
                        color: DesignTokens.success,
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space16),
                    Expanded(
                      child: _buildStatItem(
                        title: 'Total Spent',
                        value: 'A\$${userReviews.fold(0, (sum, review) => sum + (review['orderValue'] as int))}',
                        icon: Icons.account_balance_wallet,
                        color: DesignTokens.primaryRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: DesignTokens.space20),
          
          // Rating Distribution
          Container(
            padding: const EdgeInsets.all(DesignTokens.space20),
            decoration: BoxDecoration(
              color: DesignTokens.neutralWhite,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: DesignTokens.neutralGrey200.withOpacity(0.5),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating Distribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.neutralGrey900,
                  ),
                ),
                const SizedBox(height: DesignTokens.space16),
                ...List.generate(5, (index) {
                  final rating = 5 - index;
                  final count = ratingCounts[rating] ?? 0;
                  final percentage = userReviews.isEmpty ? 0.0 : (count / userReviews.length);
                  
                  return _buildRatingDistributionRow(rating, count, percentage);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.space16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: DesignTokens.space8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: DesignTokens.space4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: DesignTokens.neutralGrey600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingDistributionRow(int rating, int count, double percentage) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space8),
      child: Row(
        children: [
          Row(
            children: [
              Text(
                rating.toString(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.neutralGrey900,
                ),
              ),
              const SizedBox(width: DesignTokens.space4),
              const Icon(
                Icons.star,
                size: 16,
                color: DesignTokens.primaryOrange,
              ),
            ],
          ),
          const SizedBox(width: DesignTokens.space12),
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: DesignTokens.neutralGrey200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: DesignTokens.primaryOrange,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space12),
          SizedBox(
            width: 30,
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: DesignTokens.neutralGrey400,
          ),
          const SizedBox(height: DesignTokens.space16),
          Text(
            selectedFilter == 'All' ? 'No reviews yet' : 'No ${selectedFilter.toLowerCase()} reviews',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: DesignTokens.neutralGrey600,
            ),
          ),
          const SizedBox(height: DesignTokens.space8),
          const Text(
            'Start ordering to leave your first review!',
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.neutralGrey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: DesignTokens.space16),
      decoration: BoxDecoration(
        color: DesignTokens.neutralWhite,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: DesignTokens.neutralGrey200.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Info and Rating
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  child: Container(
                    width: 50,
                    height: 50,
                    color: DesignTokens.neutralGrey200,
                    child: const Icon(
                      Icons.restaurant,
                      color: DesignTokens.neutralGrey500,
                    ),
                  ),
                ),
                const SizedBox(width: DesignTokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['restaurantName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.neutralGrey900,
                        ),
                      ),
                      const SizedBox(height: DesignTokens.space4),
                      Text(
                        review['date'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: DesignTokens.neutralGrey500,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStarRating(review['rating']),
              ],
            ),
            
            const SizedBox(height: DesignTokens.space12),
            
            // Review Text
            Text(
              review['reviewText'],
              style: const TextStyle(
                fontSize: 14,
                color: DesignTokens.neutralGrey700,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: DesignTokens.space12),
            
            // Order Items
            Wrap(
              spacing: DesignTokens.space8,
              runSpacing: DesignTokens.space4,
              children: (review['orderItems'] as List<String>).map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.neutralGrey100,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      color: DesignTokens.neutralGrey600,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: DesignTokens.space12),
            
            // Order Value and Helpful Count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Value: A\$${review['orderValue']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: DesignTokens.neutralGrey500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.thumb_up,
                      size: 16,
                      color: DesignTokens.success,
                    ),
                    const SizedBox(width: DesignTokens.space4),
                    Text(
                      '${review['helpful']} helpful',
                      style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.neutralGrey500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            // Restaurant Reply
            if (review['restaurantReply'] != null) ...[
              const SizedBox(height: DesignTokens.space12),
              Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: DesignTokens.neutralGrey50,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSmall),
                  border: Border.all(color: DesignTokens.neutralGrey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.store,
                          size: 16,
                          color: DesignTokens.primaryOrange,
                        ),
                        SizedBox(width: DesignTokens.space4),
                        Text(
                          'Restaurant Reply',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: DesignTokens.space8),
                    Text(
                      review['restaurantReply'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: DesignTokens.neutralGrey600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: DesignTokens.primaryOrange,
        );
      }),
    );
  }
}