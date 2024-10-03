class Store {
  final String id;
  final String name;
  final String address;
  final String category;
  final double rating;
  final String image;
  final String businessOwnerId;
  final Map<String, dynamic> schedule;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.rating,
    required this.image,
    required this.businessOwnerId,
    required this.schedule,
  });

  factory Store.fromFirestore(Map<String, dynamic> json, String id) {
    return Store(
      id: id,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      businessOwnerId: json['businessOwnerId'] ?? '',
      schedule: Map<String, dynamic>.from(json['schedule'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'address': address,
      'category': category,
      'rating': rating,
      'image': image,
      'businessOwnerId': businessOwnerId,
      'schedule': schedule,
    };
  }
}