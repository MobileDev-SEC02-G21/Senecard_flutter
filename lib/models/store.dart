class Store {
  final String id;                 // ID de la tienda (proporcionado por Firestore)
  final String name;               // Nombre de la tienda
  final String address;            // Dirección física de la tienda
  final String category;           // Categoría de la tienda (restaurante, tienda, etc.)
  final double rating;             // Calificación promedio de la tienda
  final String image;              // URL de la imagen de la tienda
  final String businessOwnerId;    // ID del dueño de la tienda
  final Map<String, dynamic> schedule; // Horarios de la tienda (almacenado como un mapa de días y franjas horarias)

  Store({
    required this.id,              // Se añade el ID en el constructor
    required this.name,
    required this.address,
    required this.category,
    required this.rating,
    required this.image,
    required this.businessOwnerId,
    required this.schedule,
  });

  // Crear una instancia de Store desde un documento de Firestore
  factory Store.fromFirestore(Map<String, dynamic> json, String id) {
    return Store(
      id: id,  // El ID proviene del documento de Firestore
      name: json['name'],
      address: json['address'],
      category: json['category'],
      rating: (json['rating'] as num).toDouble(),  // Convertir el número a double
      image: json['image'],
      businessOwnerId: json['businessOwnerId'],
      schedule: Map<String, dynamic>.from(json['schedule']), // Convertir a un mapa dinámico
    );
  }

  // Convertir una instancia de Store a un mapa para Firestore
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
