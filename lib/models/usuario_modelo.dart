import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModelo {
  final String uid;
  final String email;
  final String nombreUsuario;
  final String? fotoUrl;
  final String? biografia;
  final DateTime fechaRegistro;
  final int juegosCompletados;
  final int totalHorasJugadas;
  final int logrosDesbloqueados;
  final List<String> seguidores;
  final List<String> siguiendo;
  final DateTime ultimaConexion;
  final String? nivelUsuario; // Basado en logros/actividad
  final List<String> juegosRecientes;

  UsuarioModelo({
    required this.uid,
    required this.email,
    required this.nombreUsuario,
    this.fotoUrl,
    this.biografia = '',
    required this.fechaRegistro,
    this.juegosCompletados = 0,
    this.totalHorasJugadas = 0,
    this.logrosDesbloqueados = 0,
    this.seguidores = const [],
    this.siguiendo = const [],
    required this.ultimaConexion,
    this.nivelUsuario = 'Novato',
    this.juegosRecientes = const [],
  });

  factory UsuarioModelo.fromMap(Map<String, dynamic> map) {
    return UsuarioModelo(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      nombreUsuario: map['nombreUsuario'] ?? '',
      fotoUrl: map['fotoUrl'],
      biografia: map['biografia'] ?? '',
      fechaRegistro: (map['fechaRegistro'] is Timestamp) 
          ? (map['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      juegosCompletados: map['juegosCompletados'] ?? 0,
      totalHorasJugadas: map['totalHorasJugadas'] ?? 0,
      logrosDesbloqueados: map['logrosDesbloqueados'] ?? 0,
      seguidores: List<String>.from(map['seguidores'] ?? []),
      siguiendo: List<String>.from(map['siguiendo'] ?? []),
      ultimaConexion: (map['ultimaConexion'] is Timestamp)
          ? (map['ultimaConexion'] as Timestamp).toDate()
          : DateTime.now(),
      nivelUsuario: map['nivelUsuario'] ?? 'Novato',
      juegosRecientes: List<String>.from(map['juegosRecientes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombreUsuario': nombreUsuario,
      'fotoUrl': fotoUrl,
      'biografia': biografia,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'juegosCompletados': juegosCompletados,
      'totalHorasJugadas': totalHorasJugadas,
      'logrosDesbloqueados': logrosDesbloqueados,
      'seguidores': seguidores,
      'siguiendo': siguiendo,
      'ultimaConexion': Timestamp.fromDate(ultimaConexion),
      'nivelUsuario': nivelUsuario,
      'juegosRecientes': juegosRecientes,
    };
  }

  // Método para crear una copia del modelo con campos actualizados
  UsuarioModelo copyWith({
    String? uid,
    String? email,
    String? nombreUsuario,
    String? fotoUrl,
    String? biografia,
    DateTime? fechaRegistro,
    int? juegosCompletados,
    int? totalHorasJugadas,
    int? logrosDesbloqueados,
    List<String>? seguidores,
    List<String>? siguiendo,
    DateTime? ultimaConexion,
    String? nivelUsuario,
    List<String>? juegosRecientes,
  }) {
    return UsuarioModelo(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      biografia: biografia ?? this.biografia,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      juegosCompletados: juegosCompletados ?? this.juegosCompletados,
      totalHorasJugadas: totalHorasJugadas ?? this.totalHorasJugadas,
      logrosDesbloqueados: logrosDesbloqueados ?? this.logrosDesbloqueados,
      seguidores: seguidores ?? this.seguidores,
      siguiendo: siguiendo ?? this.siguiendo,
      ultimaConexion: ultimaConexion ?? this.ultimaConexion,
      nivelUsuario: nivelUsuario ?? this.nivelUsuario,
      juegosRecientes: juegosRecientes ?? this.juegosRecientes,
    );
  }
} 