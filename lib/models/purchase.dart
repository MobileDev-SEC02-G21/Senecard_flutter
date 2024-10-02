class Purchase {
  final String id;                 // ID de la compra
  final String storeId;             // ID de la tienda
  final String uniandesMemberId;    // ID del usuario (miembro de Uniandes)
  final String date;                // Fecha de la compra
  final bool eligible;              // Indica si la compra es elegible
  final double? rating;             // Calificación de la compra (puede ser nulo)

  Purchase({
    required this.id,
    required this.storeId,
    required this.uniandesMemberId,
    required this.date,
    required this.eligible,
    this.rating,                    // Este campo puede ser nulo
  });

  // Crear una instancia de Purchase desde un documento de Firestore
  factory Purchase.fromFirestore(Map<String, dynamic> json, String id) {
    return Purchase(
      id: id,
      storeId: json['storeId'],
      uniandesMemberId: json['uniandesMemberId'],
      date: json['date'],
      eligible: json['eligible'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null, // Permitir nulos
    );
  }

  // Convertir una instancia de Purchase a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'storeId': storeId,
      'uniandesMemberId': uniandesMemberId,
      'date': date,
      'eligible': eligible,
      if (rating != null) 'rating': rating, // Solo agregar si no es nulo
    };
  }
}
