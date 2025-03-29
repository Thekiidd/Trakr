import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModelo {
  final String uid;
  final String email;
  final String nombreUsuario;
  final String? fotoUrl;
  final String? bannerUrl;
  final String? biografia;
  final String? nivelUsuario;
  final DateTime fechaRegistro;
  final List<String> seguidores;
  final List<String> siguiendo;
  final List<String> juegosRecientes;
  final List<GameList> listas;
  final int juegosCompletados;
  final int logrosDesbloqueados;
  final int totalHorasJugadas;

  UsuarioModelo({
    required this.uid,
    required this.email,
    required this.nombreUsuario,
    this.fotoUrl,
    this.bannerUrl,
    this.biografia,
    this.nivelUsuario,
    required this.fechaRegistro,
    List<String>? seguidores,
    List<String>? siguiendo,
    List<String>? juegosRecientes,
    List<GameList>? listas,
    this.juegosCompletados = 0,
    this.logrosDesbloqueados = 0,
    this.totalHorasJugadas = 0,
  }) : 
    this.seguidores = seguidores ?? [],
    this.siguiendo = siguiendo ?? [],
    this.juegosRecientes = juegosRecientes ?? [],
    this.listas = listas ?? [];

  factory UsuarioModelo.fromMap(Map<String, dynamic> map) {
    final DateTime fechaRegistro = (map['fechaRegistro'] as Timestamp).toDate();
    
    List<GameList> listas = [];
    if (map['listas'] != null) {
      listas = List<GameList>.from(
        (map['listas'] as List<dynamic>).map((lista) => GameList.fromMap(lista)),
      );
    }

    return UsuarioModelo(
      uid: map['uid'] as String,
      email: map['email'] as String,
      nombreUsuario: map['nombreUsuario'] as String,
      fotoUrl: map['fotoUrl'] as String?,
      bannerUrl: map['bannerUrl'] as String?,
      biografia: map['biografia'] as String?,
      nivelUsuario: map['nivelUsuario'] as String?,
      fechaRegistro: fechaRegistro,
      seguidores: List<String>.from(map['seguidores'] ?? []),
      siguiendo: List<String>.from(map['siguiendo'] ?? []),
      juegosRecientes: List<String>.from(map['juegosRecientes'] ?? []),
      listas: listas,
      juegosCompletados: map['juegosCompletados'] as int? ?? 0,
      logrosDesbloqueados: map['logrosDesbloqueados'] as int? ?? 0,
      totalHorasJugadas: map['totalHorasJugadas'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombreUsuario': nombreUsuario,
      'fotoUrl': fotoUrl,
      'bannerUrl': bannerUrl,
      'biografia': biografia,
      'nivelUsuario': nivelUsuario,
      'fechaRegistro': fechaRegistro,
      'seguidores': seguidores,
      'siguiendo': siguiendo,
      'juegosRecientes': juegosRecientes,
      'listas': listas.map((lista) => lista.toMap()).toList(),
      'juegosCompletados': juegosCompletados,
      'logrosDesbloqueados': logrosDesbloqueados,
      'totalHorasJugadas': totalHorasJugadas,
    };
  }

  UsuarioModelo copyWith({
    String? uid,
    String? email,
    String? nombreUsuario,
    String? fotoUrl,
    String? bannerUrl,
    String? biografia,
    String? nivelUsuario,
    DateTime? fechaRegistro,
    List<String>? seguidores,
    List<String>? siguiendo,
    List<String>? juegosRecientes,
    List<GameList>? listas,
    int? juegosCompletados,
    int? logrosDesbloqueados,
    int? totalHorasJugadas,
  }) {
    return UsuarioModelo(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombreUsuario: nombreUsuario ?? this.nombreUsuario,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      biografia: biografia ?? this.biografia,
      nivelUsuario: nivelUsuario ?? this.nivelUsuario,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      seguidores: seguidores ?? this.seguidores,
      siguiendo: siguiendo ?? this.siguiendo,
      juegosRecientes: juegosRecientes ?? this.juegosRecientes,
      listas: listas ?? this.listas,
      juegosCompletados: juegosCompletados ?? this.juegosCompletados,
      logrosDesbloqueados: logrosDesbloqueados ?? this.logrosDesbloqueados,
      totalHorasJugadas: totalHorasJugadas ?? this.totalHorasJugadas,
    );
  }
}

class GameList {
  final String id;
  final String nombre;
  final String descripcion;
  final bool esPrivada;
  final DateTime fechaCreacion;
  final List<GameInList> juegos;

  GameList({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.esPrivada,
    required this.fechaCreacion,
    List<GameInList>? juegos,
  }) : this.juegos = juegos ?? [];

  factory GameList.fromMap(Map<String, dynamic> map) {
    final DateTime fechaCreacion = map['fechaCreacion'] is Timestamp
        ? (map['fechaCreacion'] as Timestamp).toDate()
        : DateTime.parse(map['fechaCreacion'].toString());

    List<GameInList> juegos = [];
    if (map['juegos'] != null) {
      juegos = List<GameInList>.from(
        (map['juegos'] as List<dynamic>).map((juego) => GameInList.fromMap(juego)),
      );
    }

    return GameList(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      descripcion: map['descripcion'] as String? ?? '',
      esPrivada: map['esPrivada'] as bool? ?? false,
      fechaCreacion: fechaCreacion,
      juegos: juegos,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'esPrivada': esPrivada,
      'fechaCreacion': fechaCreacion,
      'juegos': juegos.map((juego) => juego.toMap()).toList(),
    };
  }

  GameList copyWith({
    String? id,
    String? nombre,
    String? descripcion,
    bool? esPrivada,
    DateTime? fechaCreacion,
    List<GameInList>? juegos,
  }) {
    return GameList(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      esPrivada: esPrivada ?? this.esPrivada,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      juegos: juegos ?? this.juegos,
    );
  }
}

class GameInList {
  final String gameId;
  final String nombre;
  final String? imagenUrl;
  final DateTime fechaAgregado;

  GameInList({
    required this.gameId,
    required this.nombre,
    this.imagenUrl,
    required this.fechaAgregado,
  });

  factory GameInList.fromMap(Map<String, dynamic> map) {
    final DateTime fechaAgregado = map['fechaAgregado'] is Timestamp
        ? (map['fechaAgregado'] as Timestamp).toDate()
        : DateTime.parse(map['fechaAgregado'].toString());

    return GameInList(
      gameId: map['gameId'] as String,
      nombre: map['nombre'] as String,
      imagenUrl: map['imagenUrl'] as String?,
      fechaAgregado: fechaAgregado,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      'fechaAgregado': fechaAgregado,
    };
  }
} 