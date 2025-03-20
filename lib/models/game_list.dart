import 'package:cloud_firestore/cloud_firestore.dart';

class GameList {
  final String id;
  final String idUsuario;
  final String titulo;
  final String descripcion;
  final List<String> idsJuegos;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;
  final bool esPublica;
  final Map<String, dynamic> metadatos;

  GameList({
    required this.id,
    required this.idUsuario,
    required this.titulo,
    this.descripcion = '',
    this.idsJuegos = const [],
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.esPublica = false,
    this.metadatos = const {},
  });

  factory GameList.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> datos = doc.data() as Map<String, dynamic>;
    return GameList(
      id: doc.id,
      idUsuario: datos['idUsuario'] ?? '',
      titulo: datos['titulo'] ?? '',
      descripcion: datos['descripcion'] ?? '',
      idsJuegos: List<String>.from(datos['idsJuegos'] ?? []),
      fechaCreacion: (datos['fechaCreacion'] as Timestamp).toDate(),
      fechaActualizacion: (datos['fechaActualizacion'] as Timestamp).toDate(),
      esPublica: datos['esPublica'] ?? false,
      metadatos: datos['metadatos'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'titulo': titulo,
      'descripcion': descripcion,
      'idsJuegos': idsJuegos,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaActualizacion': Timestamp.fromDate(fechaActualizacion),
      'esPublica': esPublica,
      'metadatos': metadatos,
    };
  }

  GameList copyWith({
    String? titulo,
    String? descripcion,
    List<String>? idsJuegos,
    bool? esPublica,
    Map<String, dynamic>? metadatos,
  }) {
    return GameList(
      id: id,
      idUsuario: idUsuario,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      idsJuegos: idsJuegos ?? this.idsJuegos,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: DateTime.now(),
      esPublica: esPublica ?? this.esPublica,
      metadatos: metadatos ?? this.metadatos,
    );
  }
} 