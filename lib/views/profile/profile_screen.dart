import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/usuario_modelo.dart';
import '../../servicios/servicio_usuario.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;
  final TextEditingController _biografiaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: CustomAppBar(
        title: 'Mi Perfil',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Cerrar Sesión',
          ),
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
                children: [
          // ... resto del contenido del perfil ...
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Mis Juegos'),
              Tab(text: 'Reseñas'),
              Tab(text: 'Actividad'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // ... contenido de las pestañas ...
              ],
            ),
                  ),
                ],
              ),
            );
          }

  Future<void> _handleLogout(BuildContext context) async {
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
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      await authViewModel.signOut();
      if (mounted) {
        context.go('/');
      }
    }
  }

  Widget _construirAppBar(UsuarioModelo usuario) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryDark,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de portada
            Image.network(
              usuario.fotoUrl ?? 'https://placeholder.com/banner',
              fit: BoxFit.cover,
            ),
            // Gradiente sobre la imagen
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.primaryDark,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: AppTheme.secondaryLight),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
            });
          },
        ),
        IconButton(
          icon: Icon(Icons.settings, color: AppTheme.secondaryLight),
          onPressed: () {
            // TODO: Implementar navegación a configuración
          },
        ),
      ],
    );
  }

  Widget _construirPerfilHeader(UsuarioModelo usuario) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
              child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
                children: [
                  CircleAvatar(
                  radius: 40,
            backgroundImage: usuario.fotoUrl != null
                ? NetworkImage(usuario.fotoUrl!)
                : null,
            child: usuario.fotoUrl == null
                      ? Icon(Icons.person, size: 40, color: AppTheme.secondaryLight)
                : null,
          ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(
            usuario.nombreUsuario,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight,
              fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                      Text(
                        'Nivel ${usuario.nivelUsuario}',
                        style: GoogleFonts.inter(
                          color: AppTheme.accentBlue,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (_isEditing)
              TextField(
                controller: _biografiaController..text = usuario.biografia ?? '',
                style: TextStyle(color: AppTheme.secondaryLight),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Biografía',
                  border: OutlineInputBorder(),
                ),
              )
            else
                    Text(
            usuario.biografia ?? 'Sin biografía',
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
                _construirContador('Siguiendo', usuario.siguiendo.length),
              _construirContador('Seguidores', usuario.seguidores.length),
                _construirContador('Juegos', usuario.juegosCompletados),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _construirTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: AppTheme.secondaryLight.withOpacity(0.7),
          tabs: [
            Tab(text: 'INFO'),
            Tab(text: 'JUEGOS'),
            Tab(text: 'LOGROS'),
            Tab(text: 'LISTAS'),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _construirTabInformacion(UsuarioModelo usuario) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        _construirSeccionEstadisticas(usuario),
        SizedBox(height: 16),
        _construirSeccionActividad(usuario),
      ],
    );
  }

  Widget _construirTabJuegos(UsuarioModelo usuario) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: usuario.juegosRecientes.length,
      itemBuilder: (context, index) {
        return _construirTarjetaJuego(usuario.juegosRecientes[index]);
      },
    );
  }

  Widget _construirTabLogros(UsuarioModelo usuario) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 10, // Ejemplo
      itemBuilder: (context, index) {
        return _construirTarjetaLogro();
      },
    );
  }

  Widget _construirTabListas(UsuarioModelo usuario) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5, // Ejemplo
      itemBuilder: (context, index) {
        return _construirTarjetaLista();
      },
    );
  }

  Widget _construirSeccionEstadisticas(UsuarioModelo usuario) {
    return Card(
        color: AppTheme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          _construirEstadisticaItem(
            'Horas Jugadas',
            '${usuario.totalHorasJugadas}h',
            Icons.timer,
          ),
          _construirEstadisticaItem(
            'Logros Desbloqueados',
              '${usuario.logrosDesbloqueados}',
            Icons.emoji_events,
          ),
          _construirEstadisticaItem(
              'Juegos Completados',
              '${usuario.juegosCompletados}',
              Icons.games,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoNuevaLista() {
    showDialog(
      context: context,
      builder: (context) {
        final nombreController = TextEditingController();
        final descripcionController = TextEditingController();
        bool esPrivada = false;

        return AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: Text(
            'Crear Nueva Lista',
            style: GoogleFonts.inter(color: AppTheme.secondaryLight),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
      child: Column(
                  mainAxisSize: MainAxisSize.min,
        children: [
                    TextField(
                      controller: nombreController,
                      style: TextStyle(color: AppTheme.secondaryLight),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la lista',
                        labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descripcionController,
                      style: TextStyle(color: AppTheme.secondaryLight),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
            ),
          ),
          SizedBox(height: 16),
                    Row(
                      children: [
            Text(
                          'Lista Privada',
                    style: TextStyle(color: AppTheme.secondaryLight),
                  ),
                        Switch(
                          value: esPrivada,
                          onChanged: (value) {
                            setState(() {
                              esPrivada = value;
                            });
                          },
                          activeColor: AppTheme.accentBlue,
                        ),
                      ],
            ),
        ],
      ),
    );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(color: AppTheme.secondaryLight),
              ),
            ),
                    ElevatedButton(
              onPressed: () {
                // TODO: Implementar creación de lista
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentBlue,
              ),
              child: Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  Widget _construirContador(String titulo, int cantidad) {
    return Column(
      children: [
        Text(
          cantidad.toString(),
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          titulo,
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight.withOpacity(0.7),
            fontSize: 16,
                      ),
                    ),
                  ],
    );
  }

  Widget _construirEstadisticaItem(String titulo, String valor, IconData icono) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icono, color: AppTheme.accentBlue),
          SizedBox(width: 16),
          Text(
            titulo,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          Spacer(),
          Text(
            valor,
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight,
              fontSize: 16,
              fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _construirSeccionActividad(UsuarioModelo usuario) {
    // Implementa la lógica para construir la sección de actividad
    return Container(); // Placeholder, actual implementación necesaria
  }

  Widget _construirTarjetaJuego(String juego) {
    // Implementa la lógica para construir una tarjeta de juego
    return Container(); // Placeholder, actual implementación necesaria
  }

  Widget _construirTarjetaLogro() {
    // Implementa la lógica para construir una tarjeta de logro
    return Container(); // Placeholder, actual implementación necesaria
  }

  Widget _construirTarjetaLista() {
    // Implementa la lógica para construir una tarjeta de lista
    return Container(); // Placeholder, actual implementación necesaria
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.primaryDark,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}