import 'package:cloud_firestore/cloud_firestore.dart';

class ForumPost {
  final String id;
  final String idUsuario;
  final String titulo;
  final String contenido;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final List<String> etiquetas;
  final int contadorMeGusta;
  final int contadorComentarios;
  final String? idJuego;
  final Map<String, dynamic> metadatos;

  ForumPost({
    required this.id,
    required this.idUsuario,
    required this.titulo,
    required this.contenido,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.etiquetas = const [],
    this.contadorMeGusta = 0,
    this.contadorComentarios = 0,
    this.idJuego,
    this.metadatos = const {},
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      idUsuario: datos['idUsuario'] ?? '',
      titulo: datos['titulo'] ?? '',
      contenido: datos['contenido'] ?? '',
      fechaCreacion: (datos['fechaCreacion'] as Timestamp).toDate(),
      fechaActualizacion: (datos['fechaActualizacion'] as Timestamp).toDate(),
      etiquetas: List<String>.from(datos['etiquetas'] ?? []),
      contadorMeGusta: datos['contadorMeGusta'] ?? 0,
      contadorComentarios: datos['contadorComentarios'] ?? 0,
      idJuego: datos['idJuego'],
      metadatos: datos['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'titulo': titulo,
      'contenido': contenido,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
      'etiquetas': etiquetas,
      'contadorMeGusta': contadorMeGusta,
      'contadorComentarios': contadorComentarios,
      'idJuego': idJuego,
      'metadatos': metadatos,
    };
  }

  ForumPost copyWith({
    String? titulo,
    String? contenido,
    List<String>? etiquetas,
    int? contadorMeGusta,
    int? contadorComentarios,
    String? idJuego,
    Map<String, dynamic>? metadatos,
  }) {
    return ForumPost(
      id: id,
      idUsuario: idUsuario,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
      etiquetas: etiquetas ?? this.etiquetas,
      contadorMeGusta: contadorMeGusta ?? this.contadorMeGusta,
      contadorComentarios: contadorComentarios ?? this.contadorComentarios,
      idJuego: idJuego ?? this.idJuego,
      metadatos: metadatos ?? this.metadatos,
    );
  }
} 