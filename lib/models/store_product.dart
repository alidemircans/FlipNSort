class StoreProduct {
  final String identifier;
  final String description;
  final String title;
  final double price;
  final String priceString;
  final String currencyCode;
  final dynamic introductoryPrice;
  final List<dynamic> discounts;
  final String productCategory;
  final dynamic defaultOption;
  final dynamic subscriptionOptions;
  final dynamic presentedOfferingContext;
  final dynamic subscriptionPeriod;

  StoreProduct({
    required this.identifier,
    required this.description,
    required this.title,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    this.introductoryPrice,
    required this.discounts,
    required this.productCategory,
    this.defaultOption,
    this.subscriptionOptions,
    this.presentedOfferingContext,
    this.subscriptionPeriod,
  });

  factory StoreProduct.fromMap(Map<String, dynamic> map) {
    return StoreProduct(
      identifier: map['identifier'],
      description: map['description'],
      title: map['title'],
      price: map['price'],
      priceString: map['priceString'],
      currencyCode: map['currencyCode'],
      introductoryPrice: map['introductoryPrice'],
      discounts: List<dynamic>.from(map['discounts']),
      productCategory: map['productCategory'],
      defaultOption: map['defaultOption'],
      subscriptionOptions: map['subscriptionOptions'],
      presentedOfferingContext: map['presentedOfferingContext'],
      subscriptionPeriod: map['subscriptionPeriod'],
    );
  }
}
