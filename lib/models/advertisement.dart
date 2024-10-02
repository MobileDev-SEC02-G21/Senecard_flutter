class Advertisement {
  final String id;            // ID del anuncio
  final String storeId;        // ID de la tienda correspondiente
  final String title;          // Título del anuncio
  final String description;    // Descripción del anuncio
  final String image;          // URL de la imagen del anuncio
  final String startDate;      // Fecha de inicio del anuncio
  final String? endDate;       // Fecha de finalización del anuncio (puede ser nula)
  final bool available;        // Estado de disponibilidad del anuncio

  Advertisement({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.image,
    required this.startDate,
    this.endDate,              // Este campo puede ser nulo
    required this.available,
  });

  // Crear un Advertisement desde un documento de Firestore
  factory Advertisement.fromFirestore(Map<String, dynamic> json, String id) {
    return Advertisement(
      id: id,
      storeId: json['storeId'],
      title: json['title'],
      description: json['description'],
      image: json['image'],
      startDate: json['startDate'],
      endDate: json['endDate'],        // Puede ser nulo, no necesita el `?? null`
      available: json['available'],
    );
  }

  // Convertir un Advertisement a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'title': title,
      'description': description,
      'image': image,
      'startDate': startDate,
      'endDate': endDate,              // Puede ser nulo
      'available': available,
    };
  }
}
