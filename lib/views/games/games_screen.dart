// lib/views/games/games_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/game.dart';
import '../../services/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late Future<List<Game>> _gamesFuture;
  String _searchQuery = '';
  String _ordering = '-rating'; // Por defecto ordenamos por mejor rating
  int _currentPage = 1;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadGames() {
    setState(() {
      _gamesFuture = ApiService().fetchGames(
        searchQuery: _searchQuery,
        ordering: _ordering,
        page: _currentPage,
      );
    });
  }

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
      _currentPage = 1; // Reiniciar a página 1 cuando se busca
    });
    _loadGames();
    // Cerrar el teclado
    FocusScope.of(context).unfocus();
  }

  void _cancelSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadGames();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
        _loadGames();
      }
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authViewModel.signOut();
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: _isSearching
          ? AppBar(
              backgroundColor: AppTheme.primaryDark,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _cancelSearch,
              ),
              title: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar juegos...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _performSearch(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _performSearch,
                ),
              ],
            )
          : CustomAppBar(
              title: 'Games',
              backRoute: '/',
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: _toggleSearch,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort, color: Colors.white),
                  onSelected: (value) {
                    setState(() {
                      _ordering = value;
                    });
                    _loadGames();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: '-rating',
                      child: Text('Mejor valorados'),
                    ),
                    const PopupMenuItem(
                      value: '-released',
                      child: Text('Más recientes'),
                    ),
                    const PopupMenuItem(
                      value: 'name',
                      child: Text('Nombre (A-Z)'),
                    ),
                    const PopupMenuItem(
                      value: '-name',
                      child: Text('Nombre (Z-A)'),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Resultados para: "$_searchQuery"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.clear, color: Colors.white70),
                      label: const Text('Limpiar', style: TextStyle(color: Colors.white70)),
                      onPressed: () {
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                        _loadGames();
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: FutureBuilder<List<Game>>(
                future: _gamesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final games = snapshot.data ?? [];
                  if (games.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.videogame_asset_off,
                            color: Colors.white54,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No hay juegos disponibles'
                                : 'No se encontraron juegos para "$_searchQuery"',
                            style: const TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      final game = games[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => context.push('/game-details/${game.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: game.coverImage.isNotEmpty
                                    ? Image.network(
                                        game.coverImage,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: Icon(Icons.broken_image, color: Colors.white70, size: 40),
                                            ),
                                          );
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Container(
                                            color: Colors.grey.shade800,
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: Colors.grey.shade800,
                                        child: const Icon(Icons.videogame_asset, color: Colors.white70, size: 40),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      game.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (game.rating != null && game.rating > 0) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, size: 16, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(game.rating.toStringAsFixed(1)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () {
          // Cargar más juegos (paginación)
          setState(() {
            _currentPage++;
          });
          _loadGames();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
