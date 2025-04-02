import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/game.dart';
import '../../services/api_service.dart';
import '../../services/user_service.dart';
import '../../widgets/custom_app_bar.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;

  const GameDetailsScreen({
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  _GameDetailsScreenState createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  late Future<Game> _gameFuture;
  Game? _game;
  bool _isLoading = true;
  bool _isAddingToProfile = false;
  bool _isInFavorites = false;
  String? _error;
  
  // Lista de listas disponibles
  final List<String> _listas = ['Jugando', 'Completados', 'Pendientes', 'Abandonados'];
  String? _listaSeleccionada;
  
  final UserService _userService = UserService();
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadGameDetails();
  }

  Future<void> _loadGameDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final game = await _apiService.fetchGameById(widget.gameId);
      
      setState(() {
        _game = game;
        _isLoading = false;
      });
      
      // Verificar si el juego ya está en favoritos
      _verificarSiEstaEnFavoritos();
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los detalles del juego: $e';
        _isLoading = false;
      });
      print('Error al cargar los detalles del juego: $e');
    }
  }
  
  Future<void> _verificarSiEstaEnFavoritos() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || _game == null) return;
    
    try {
      final docSnapshot = await _firestore
          .collection('usuarios')
          .doc(currentUser.uid)
          .collection('juegos')
          .doc(_game!.id)
          .get();
      
      setState(() {
        _isInFavorites = docSnapshot.exists;
      });
    } catch (e) {
      print('Error al verificar si el juego está en favoritos: $e');
    }
  }

  Future<void> _agregarJuegoAFavoritos() async {
    if (_game == null) return;
    
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para añadir juegos a favoritos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isAddingToProfile = true;
    });
    
    try {
      // Si ya está en favoritos, lo quitamos
      if (_isInFavorites) {
        await _firestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .collection('juegos')
            .doc(_game!.id)
            .delete();
        
        // Eliminar también de la lista de favoritos en el documento principal
        try {
          final userDoc = await _firestore.collection('usuarios').doc(currentUser.uid).get();
          
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            
            if (userData.containsKey('listas')) {
              List<dynamic> listas = List.from(userData['listas']);
              
              // Encontrar la lista de favoritos
              int favoritosIndex = listas.indexWhere((lista) => lista['id'] == 'favoritos');
              
              if (favoritosIndex != -1 && listas[favoritosIndex].containsKey('juegos')) {
                // Filtrar el juego que estamos eliminando
                List<dynamic> juegos = List.from(listas[favoritosIndex]['juegos']);
                juegos = juegos.where((juego) => juego['id'] != _game!.id).toList();
                
                // Actualizar la lista de juegos
                listas[favoritosIndex]['juegos'] = juegos;
                
                // Guardar los cambios
                await _firestore.collection('usuarios').doc(currentUser.uid).update({
                  'listas': listas,
                });
              }
            }
          }
        } catch (e) {
          print('Error al eliminar juego de la lista de favoritos: $e');
        }
        
        // Intentar actualizar estadísticas (podría fallar si el documento no existe)
        try {
          await _firestore.collection('usuarios').doc(currentUser.uid).update({
            'stats.totalJuegos': FieldValue.increment(-1),
            'stats.totalFavoritos': FieldValue.increment(-1),
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });
        } catch (statsError) {
          print('Error al actualizar estadísticas: $statsError');
          // Crear documento de estadísticas si no existe
          await _firestore.collection('usuarios').doc(currentUser.uid).set({
            'stats': {
              'totalJuegos': 0,
              'totalFavoritos': 0,
            },
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Juego eliminado de favoritos'),
            backgroundColor: Colors.blue,
          ),
        );
        
        setState(() {
          _isInFavorites = false;
        });
      } else {
        // Si no está en favoritos, lo agregamos
        final juegoData = {
          'id': _game!.id,
          'titulo': _game!.title,
          'imagen': _game!.coverImage,
          'genero': _game!.genre,
          'plataforma': _game!.platform,
          'valoracion': _game!.rating,
          'fechaAgregado': FieldValue.serverTimestamp(),
          'descripcion': 'Añadido a favoritos',
          'estado': 'favorito',
          'tiempoJugado': 0,
          'nombre': _game!.title, // Campo adicional para compatibilidad
          'imagenUrl': _game!.coverImage, // Campo adicional para compatibilidad
          'rating': _game!.rating,
        };
        
        // Asegurarnos que el documento del usuario existe
        await _firestore.collection('usuarios').doc(currentUser.uid).set({
          'uid': currentUser.uid,
          'email': currentUser.email,
          'ultimaActualizacion': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        // Agregar a colección de juegos del usuario
        await _firestore
            .collection('usuarios')
            .doc(currentUser.uid)
            .collection('juegos')
            .doc(_game!.id)
            .set(juegoData);
        
        // Agregar el juego a la lista "favoritos" en el documento principal del usuario
        try {
          // Comprobar si el usuario ya tiene una estructura de listas
          final userDoc = await _firestore.collection('usuarios').doc(currentUser.uid).get();
          
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            List<dynamic> listas = List.from(userData['listas'] ?? []);
            
            // Buscar si existe la lista "favoritos"
            int favoritosIndex = listas.indexWhere((lista) => lista['id'] == 'favoritos');
            
            // Si no existe la lista de favoritos, la creamos
            if (favoritosIndex == -1) {
              listas.add({
                'id': 'favoritos',
                'nombre': 'Favoritos',
                'descripcion': 'Mis juegos favoritos',
                'juegos': [],
              });
              favoritosIndex = listas.length - 1;
            }
            
            // Aseguramos que la lista tenga un array de juegos
            if (!listas[favoritosIndex].containsKey('juegos')) {
              listas[favoritosIndex]['juegos'] = [];
            }
            
            // Verificar si el juego ya existe en la lista
            List<dynamic> juegos = List.from(listas[favoritosIndex]['juegos']);
            if (!juegos.any((juego) => juego['id'] == _game!.id)) {
              // Agregar el juego a la lista
              juegos.add({
                'id': _game!.id,
                'nombre': _game!.title,
                'imagen': _game!.coverImage,
                'imagenUrl': _game!.coverImage,
                'fechaAgregado': FieldValue.serverTimestamp(),
                'estado': 'favorito',
                'rating': _game!.rating,
                'tiempoJugado': 0,
              });
              
              listas[favoritosIndex]['juegos'] = juegos;
              
              // Actualizar el documento con los cambios
              await _firestore.collection('usuarios').doc(currentUser.uid).update({
                'listas': listas,
              });
            }
          } else {
            // Crear el documento con una estructura inicial
            await _firestore.collection('usuarios').doc(currentUser.uid).set({
              'uid': currentUser.uid,
              'email': currentUser.email,
              'listas': [
                {
                  'id': 'favoritos',
                  'nombre': 'Favoritos',
                  'descripcion': 'Mis juegos favoritos',
                  'juegos': [
                    {
                      'id': _game!.id,
                      'nombre': _game!.title,
                      'imagen': _game!.coverImage,
                      'imagenUrl': _game!.coverImage,
                      'fechaAgregado': FieldValue.serverTimestamp(),
                      'estado': 'favorito',
                      'rating': _game!.rating,
                      'tiempoJugado': 0,
                    }
                  ],
                }
              ],
              'ultimaActualizacion': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }
        } catch (listError) {
          print('Error al actualizar la lista de favoritos: $listError');
        }
        
        // Intentar actualizar estadísticas (podría fallar si el documento no existe)
        try {
          await _firestore.collection('usuarios').doc(currentUser.uid).update({
            'stats.totalJuegos': FieldValue.increment(1),
            'stats.totalFavoritos': FieldValue.increment(1),
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          });
        } catch (statsError) {
          print('Error al actualizar estadísticas: $statsError');
          // Crear documento de estadísticas si no existe
          await _firestore.collection('usuarios').doc(currentUser.uid).set({
            'stats': {
              'totalJuegos': 1,
              'totalFavoritos': 1,
            },
            'ultimaActualizacion': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Juego añadido a favoritos'),
            backgroundColor: Colors.green,
          ),
        );
        
        setState(() {
          _isInFavorites = true;
        });
      }
    } catch (e) {
      String errorMessage = 'Error desconocido';
      
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'No tienes permisos para realizar esta acción. Comprueba las reglas de seguridad.';
      } else if (e.toString().contains('not-found')) {
        errorMessage = 'No se encontró el documento del usuario. Intenta cerrar sesión y volver a iniciarla.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Error de red. Verifica tu conexión a internet.';
      } else {
        errorMessage = 'Error: ${e.toString()}';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      print('Error al modificar favoritos: $e');
    } finally {
      setState(() {
        _isAddingToProfile = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: _game?.title ?? 'Detalles del Juego',
        backRoute: '/games',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : _buildGameDetails(),
      floatingActionButton: !_isLoading && _error == null && _game != null
          ? FloatingActionButton.extended(
              onPressed: _isAddingToProfile ? null : _agregarJuegoAFavoritos,
              backgroundColor: _isInFavorites ? Colors.red : AppTheme.accent,
              icon: _isAddingToProfile
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Icon(_isInFavorites ? Icons.favorite : Icons.favorite_border),
              label: Text(_isAddingToProfile 
                  ? 'Procesando...' 
                  : (_isInFavorites ? 'Quitar de favoritos' : 'Añadir a favoritos')),
            )
          : null,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el juego',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Verifica tu conexión a internet e intenta nuevamente',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadGameDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameDetails() {
    if (_game == null) return const SizedBox.shrink();
    
    final game = _game!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de portada
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: game.coverImage.isNotEmpty
                ? Image.network(
                    game.coverImage,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 64,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.videogame_asset,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Título
          Text(
            game.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          
          const SizedBox(height: 8),
          
          // Metadatos (género, plataforma, valoración)
          _buildMetadata(game),
          
          const SizedBox(height: 24),
          
          // Descripción
          if (game.description.isNotEmpty) ...[
            Text(
              'Descripción',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              game.description,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
          ],
          
          // Etiquetas
          if (game.tags.isNotEmpty) ...[
            Text(
              'Etiquetas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: game.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppTheme.secondary,
                  labelStyle: const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ],
          
          // Espacio para el botón flotante
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildMetadata(Game game) {
    return Row(
      children: [
        // Valoración
        if (game.rating > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16),
                const SizedBox(width: 4),
                Text(
                  game.rating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Género
        if (game.genre.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              game.genre,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        
        // Plataforma
        if (game.platform.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              game.platform,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
} 