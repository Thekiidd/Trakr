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
    final DateTime fechaRegistro = map['fechaRegistro'] is Timestamp
        ? (map['fechaRegistro'] as Timestamp).toDate()
        : DateTime.now();
    
    List<GameList> listas = [];
    if (map['listas'] != null) {
      listas = List<GameList>.from(
        (map['listas'] as List<dynamic>).map((lista) => GameList.fromMap(lista)),
      );
    }

    return UsuarioModelo(
      uid: map['uid']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      nombreUsuario: map['nombreUsuario']?.toString() ?? map['email']?.toString().split('@')[0] ?? 'Usuario',
      fotoUrl: map['fotoUrl']?.toString(),
      bannerUrl: map['bannerUrl']?.toString(),
      biografia: map['biografia']?.toString(),
      nivelUsuario: map['nivelUsuario']?.toString() ?? 'Novato',
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
  final int tiempoJugado; // en minutos
  final double rating; // de 0 a 5
  final String estado; // 'Jugando', 'Completado', 'En pausa', 'Abandonado'
  final String? plataforma; // 'PC', 'PS5', 'Xbox', etc.
  final String? notas; // notas personales sobre el juego

  GameInList({
    required this.gameId,
    required this.nombre,
    this.imagenUrl,
    required this.fechaAgregado,
    this.tiempoJugado = 0,
    this.rating = 0.0,
    this.estado = 'Jugando',
    this.plataforma,
    this.notas,
  });

  factory GameInList.fromMap(Map<String, dynamic> map) {
    final DateTime fechaAgregado = map['fechaAgregado'] is Timestamp
        ? (map['fechaAgregado'] as Timestamp).toDate()
        : DateTime.parse(map['fechaAgregado'].toString());

    return GameInList(
      gameId: map['id'] as String? ?? map['gameId'] as String,
      nombre: map['nombre'] as String,
      imagenUrl: map['imagenUrl'] as String?,
      fechaAgregado: fechaAgregado,
      tiempoJugado: map['tiempoJugado'] as int? ?? 0,
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      estado: map['estado'] as String? ?? 'Jugando',
      plataforma: map['plataforma'] as String?,
      notas: map['notas'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': gameId,
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      'fechaAgregado': fechaAgregado,
      'tiempoJugado': tiempoJugado,
      'rating': rating,
      'estado': estado,
      'plataforma': plataforma,
      'notas': notas,
    };
  }

  GameInList copyWith({
    String? gameId,
    String? nombre,
    String? imagenUrl,
    DateTime? fechaAgregado,
    int? tiempoJugado,
    double? rating,
    String? estado,
    String? plataforma,
    String? notas,
  }) {
    return GameInList(
      gameId: gameId ?? this.gameId,
      nombre: nombre ?? this.nombre,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      fechaAgregado: fechaAgregado ?? this.fechaAgregado,
      tiempoJugado: tiempoJugado ?? this.tiempoJugado,
      rating: rating ?? this.rating,
      estado: estado ?? this.estado,
      plataforma: plataforma ?? this.plataforma,
      notas: notas ?? this.notas,
    );
  }
} 