import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String idUsuario;
  final String idJuego;
  final double calificacion;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final int contadorMeGusta;
  final List<String> etiquetas;
  final Map<String, dynamic> metadatos;

  Review({
    required this.id,
    required this.idUsuario,
    required this.idJuego,
    required this.calificacion,
    required this.contenido,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.contadorMeGusta = 0,
    this.etiquetas = const [],
    this.metadatos = const {},
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      idUsuario: datos['idUsuario'] ?? '',
      idJuego: datos['idJuego'] ?? '',
      calificacion: (datos['calificacion'] ?? 0.0).toDouble(),
      contenido: datos['contenido'] ?? '',
      fechaCreacion: (datos['fechaCreacion'] as Timestamp).toDate(),
      fechaActualizacion: (datos['fechaActualizacion'] as Timestamp).toDate(),
      contadorMeGusta: datos['contadorMeGusta'] ?? 0,
      etiquetas: List<String>.from(datos['etiquetas'] ?? []),
      metadatos: datos['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'idJuego': idJuego,
      'calificacion': calificacion,
      'contenido': contenido,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
      'contadorMeGusta': contadorMeGusta,
      'etiquetas': etiquetas,
      'metadatos': metadatos,
    };
  }

  Review copyWith({
    double? calificacion,
    String? contenido,
    int? contadorMeGusta,
    List<String>? etiquetas,
    Map<String, dynamic>? metadatos,
  }) {
    return Review(
      id: id,
      idUsuario: idUsuario,
      idJuego: idJuego,
      calificacion: calificacion ?? this.calificacion,
      contenido: contenido ?? this.contenido,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
      contadorMeGusta: contadorMeGusta ?? this.contadorMeGusta,
      etiquetas: etiquetas ?? this.etiquetas,
      metadatos: metadatos ?? this.metadatos,
    );
  }
} 