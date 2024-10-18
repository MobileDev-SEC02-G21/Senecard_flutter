class Purchase {
  final String id;                 // ID de la compra
  final String loyaltyCardId;       // ID de la tarjeta de lealtad
  final String date;                // Fecha de la compra
  final bool isEligible;            // Indica si la compra es elegible
  final double? rating;             // Calificación de la compra (puede ser nulo)

  Purchase({
    required this.id,
    required this.loyaltyCardId,
    required this.date,
    required this.isEligible,       // Cambiado a isEligible
    this.rating,                    // Este campo puede ser nulo
  });

  // Crear una instancia de Purchase desde un documento de Firestore
  factory Purchase.fromFirestore(Map<String, dynamic> json, String id) {
    return Purchase(
      id: id,
      loyaltyCardId: json['loyaltyCardId'],  // Nuevo campo
      date: json['date'],
      isEligible: json['isElegible'],  // Cambiado a 'isElegible'
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null, // Permitir nulos
    );
  }

  // Convertir una instancia de Purchase a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'loyaltyCardId': loyaltyCardId,  // Agregar nuevo campo
      'date': date,
      'isElegible': isEligible,        // Cambiado a 'isElegible'
      if (rating != null) 'rating': rating, // Solo agregar si no es nulo
    };
  }
}
