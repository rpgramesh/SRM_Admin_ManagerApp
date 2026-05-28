class LoyaltyPoint {
  final String id;
  final String userId;
  final int points;
  final String source; // 'order', 'referral', 'bonus'
  final DateTime createdAt;
  final String? orderId;
  final String? description;

  LoyaltyPoint({
    required this.id,
    required this.userId,
    required this.points,
    required this.source,
    required this.createdAt,
    this.orderId,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'points': points,
      'source': source,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'orderId': orderId,
      'description': description,
    };
  }

  factory LoyaltyPoint.fromMap(Map<String, dynamic> map) {
    return LoyaltyPoint(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      points: map['points']?.toInt() ?? 0,
      source: map['source'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      orderId: map['orderId'],
      description: map['description'],
    );
  }
}

class UserLoyaltyData {
  final String userId;
  final int totalPoints;
  final int usedPoints;
  final int availablePoints;
  final DateTime lastUpdated;
  final List<String> redeemedRewards;

  UserLoyaltyData({
    required this.userId,
    required this.totalPoints,
    required this.usedPoints,
    required this.availablePoints,
    required this.lastUpdated,
    required this.redeemedRewards,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalPoints': totalPoints,
      'usedPoints': usedPoints,
      'availablePoints': availablePoints,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'redeemedRewards': redeemedRewards,
    };
  }

  factory UserLoyaltyData.fromMap(Map<String, dynamic> map) {
    return UserLoyaltyData(
      userId: map['userId'] ?? '',
      totalPoints: map['totalPoints']?.toInt() ?? 0,
      usedPoints: map['usedPoints']?.toInt() ?? 0,
      availablePoints: map['availablePoints']?.toInt() ?? 0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] ?? 0),
      redeemedRewards: List<String>.from(map['redeemedRewards'] ?? []),
    );
  }
}

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final String type; // 'discount', 'free_item', 'cashback'
  final double value; // discount percentage or cashback amount
  final String? itemId; // for free items
  final bool isActive;
  final DateTime? expiryDate;
  final String iconName;
  final String color;

  LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.type,
    required this.value,
    this.itemId,
    required this.isActive,
    this.expiryDate,
    required this.iconName,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsCost': pointsCost,
      'type': type,
      'value': value,
      'itemId': itemId,
      'isActive': isActive,
      'expiryDate': expiryDate?.millisecondsSinceEpoch,
      'iconName': iconName,
      'color': color,
    };
  }

  factory LoyaltyReward.fromMap(Map<String, dynamic> map) {
    return LoyaltyReward(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pointsCost: map['pointsCost']?.toInt() ?? 0,
      type: map['type'] ?? '',
      value: map['value']?.toDouble() ?? 0.0,
      itemId: map['itemId'],
      isActive: map['isActive'] ?? true,
      expiryDate: map['expiryDate'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['expiryDate'])
          : null,
      iconName: map['iconName'] ?? '',
      color: map['color'] ?? '',
    );
  }
}