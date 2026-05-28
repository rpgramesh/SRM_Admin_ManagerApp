class PromoCode {
  final String id;
  final String code;
  final String title;
  final String description;
  final String type; // 'percentage', 'fixed_amount', 'free_delivery'
  final double value; // discount percentage or fixed amount
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime validFrom;
  final DateTime validUntil;
  final bool isActive;
  final int? usageLimit;
  final int usageCount;
  final List<String> applicableCategories;
  final List<String> excludedItems;
  final bool isFirstOrderOnly;
  final String iconName;
  final String color;

  PromoCode({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    this.minOrderAmount,
    this.maxDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.usageLimit,
    required this.usageCount,
    required this.applicableCategories,
    required this.excludedItems,
    required this.isFirstOrderOnly,
    required this.iconName,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'type': type,
      'value': value,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'validFrom': validFrom.millisecondsSinceEpoch,
      'validUntil': validUntil.millisecondsSinceEpoch,
      'isActive': isActive,
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'applicableCategories': applicableCategories,
      'excludedItems': excludedItems,
      'isFirstOrderOnly': isFirstOrderOnly,
      'iconName': iconName,
      'color': color,
    };
  }

  factory PromoCode.fromMap(Map<String, dynamic> map) {
    return PromoCode(
      id: map['id'] ?? '',
      code: map['code'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? '',
      value: map['value']?.toDouble() ?? 0.0,
      minOrderAmount: map['minOrderAmount']?.toDouble(),
      maxDiscountAmount: map['maxDiscountAmount']?.toDouble(),
      validFrom: DateTime.fromMillisecondsSinceEpoch(map['validFrom'] ?? 0),
      validUntil: DateTime.fromMillisecondsSinceEpoch(map['validUntil'] ?? 0),
      isActive: map['isActive'] ?? true,
      usageLimit: map['usageLimit']?.toInt(),
      usageCount: map['usageCount']?.toInt() ?? 0,
      applicableCategories: List<String>.from(map['applicableCategories'] ?? []),
      excludedItems: List<String>.from(map['excludedItems'] ?? []),
      isFirstOrderOnly: map['isFirstOrderOnly'] ?? false,
      iconName: map['iconName'] ?? '',
      color: map['color'] ?? '',
    );
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);
  bool get isValid => isActive && !isExpired && DateTime.now().isAfter(validFrom);
  bool get hasUsageLimit => usageLimit != null;
  bool get isUsageLimitReached => hasUsageLimit && usageCount >= usageLimit!;
}

class UserPromoCodeUsage {
  final String id;
  final String userId;
  final String promoCodeId;
  final String promoCode;
  final DateTime usedAt;
  final String orderId;
  final double discountAmount;
  final double orderAmount;

  UserPromoCodeUsage({
    required this.id,
    required this.userId,
    required this.promoCodeId,
    required this.promoCode,
    required this.usedAt,
    required this.orderId,
    required this.discountAmount,
    required this.orderAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'promoCodeId': promoCodeId,
      'promoCode': promoCode,
      'usedAt': usedAt.millisecondsSinceEpoch,
      'orderId': orderId,
      'discountAmount': discountAmount,
      'orderAmount': orderAmount,
    };
  }

  factory UserPromoCodeUsage.fromMap(Map<String, dynamic> map) {
    return UserPromoCodeUsage(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      promoCodeId: map['promoCodeId'] ?? '',
      promoCode: map['promoCode'] ?? '',
      usedAt: DateTime.fromMillisecondsSinceEpoch(map['usedAt'] ?? 0),
      orderId: map['orderId'] ?? '',
      discountAmount: map['discountAmount']?.toDouble() ?? 0.0,
      orderAmount: map['orderAmount']?.toDouble() ?? 0.0,
    );
  }
}