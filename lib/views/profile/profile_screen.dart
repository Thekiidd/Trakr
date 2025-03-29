import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';
import '../../models/usuario_modelo.dart';
import '../../servicios/servicio_usuario.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  late TabController _tabController;
  final TextEditingController _biografiaController = TextEditingController();
  final ServicioUsuario _servicioUsuario = ServicioUsuario();
  String _nombreUsuarioController = '';
  File? _imagenPerfilSeleccionada;
  File? _imagenBannerSeleccionada;

  late UserViewModel _userViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // El UserViewModel ahora maneja la carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _userViewModel = Provider.of<UserViewModel>(context, listen: false);
      
      // Si no hay usuario cargado, intentamos cargarlo
      if (_userViewModel.usuario == null) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          _userViewModel.cargarPerfilUsuario(user.uid);
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _biografiaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserViewModel>(
      builder: (context, userViewModel, child) {
        _userViewModel = userViewModel;
        
        return Scaffold(
          backgroundColor: AppTheme.primaryDark,
          appBar: CustomAppBar(
            title: 'Mi Perfil',
            backRoute: '/',
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
                  if (_isEditing) {
                    _guardarCambios();
                  } else {
                    setState(() {
                      _isEditing = true;
                      
                      // Inicializa el controlador cuando entramos en modo edición
                      if (userViewModel.usuario != null) {
                        _biografiaController.text = userViewModel.usuario!.biografia ?? '';
                      }
                    });
                  }
                },
                tooltip: _isEditing ? 'Guardar Cambios' : 'Editar Perfil',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: userViewModel.isLoading 
              ? _buildLoadingIndicator() 
              : (userViewModel.errorMessage != null) 
                  ? _buildErrorMessage(userViewModel.errorMessage!) 
                  : (userViewModel.usuario == null)
                      ? _buildErrorMessage('No se pudo cargar el perfil de usuario')
                      : _buildProfileContent(userViewModel.usuario!),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.accentBlue),
          const SizedBox(height: 16),
          Text(
            'Cargando tu perfil...',
            style: GoogleFonts.inter(
              color: AppTheme.secondaryLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error',
            style: GoogleFonts.montserrat(
              color: AppTheme.secondaryLight,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                _userViewModel.cargarPerfilUsuario(user.uid);
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(UsuarioModelo usuario) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          _construirAppBar(usuario),
          _construirPerfilHeader(usuario),
          _construirTabBar(),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _construirTabInformacion(usuario),
          _construirTabJuegos(usuario),
          _construirTabLogros(usuario),
          _construirTabListas(usuario),
        ],
      ),
    );
  }

  Future<void> _guardarCambios() async {
    if (_userViewModel.usuario == null) return;

    // Utilizamos el UserViewModel para guardar los cambios
    try {
      await _userViewModel.guardarCambiosUsuario(
        biografia: _biografiaController.text,
        nombreUsuario: _nombreUsuarioController.isNotEmpty 
          ? _nombreUsuarioController 
          : _userViewModel.usuario!.nombreUsuario,
      );

      // Si hay imágenes para subir, lo haríamos aquí
      // pero solo cambiamos el estado de edición
      setState(() {
        _isEditing = false;
        _nombreUsuarioController = '';
        _imagenPerfilSeleccionada = null;
        _imagenBannerSeleccionada = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el perfil: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
            // Banner personalizado o gradiente por defecto
            usuario.bannerUrl != null && usuario.bannerUrl!.isNotEmpty
                ? Image.network(
                    usuario.bannerUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultBanner();
                    },
                  )
                : _buildDefaultBanner(),
                
            // Overlay oscuro para mejorar legibilidad
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            
            // Botón para cambiar el banner (solo visible en modo edición)
            if (_isEditing)
              Positioned(
                bottom: 16,
                right: 16,
                child: ElevatedButton.icon(
                  onPressed: _seleccionarImagenBanner,
                  icon: const Icon(Icons.image, size: 18),
                  label: const Text('Cambiar Banner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue.withOpacity(0.8),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  // Banner predeterminado con gradiente
  Widget _buildDefaultBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accentBlue.withOpacity(0.3),
            AppTheme.primaryDark,
          ],
        ),
      ),
      child: Opacity(
        opacity: 0.15,
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/pattern.png?alt=media',
          repeat: ImageRepeat.repeat,
        ),
      ),
    );
  }

  Widget _construirPerfilHeader(UsuarioModelo usuario) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar con opción para cambiar
                Stack(
                  children: [
                    // Avatar principal
                    Hero(
                      tag: 'user-avatar-${usuario.uid}',
                      child: GestureDetector(
                        onTap: _isEditing ? _seleccionarImagenPerfil : null,
                        child: Container(
                          width: isMobile ? 80 : 100,
                          height: isMobile ? 80 : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.accentBlue,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentBlue.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: usuario.fotoUrl != null && usuario.fotoUrl!.isNotEmpty
                                ? Image.network(
                                    usuario.fotoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, err, _) => Container(
                                      color: AppTheme.secondaryDark,
                                      child: Icon(
                                        Icons.person,
                                        size: isMobile ? 40 : 50,
                                        color: AppTheme.secondaryLight,
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: AppTheme.secondaryDark,
                                    child: Icon(
                                      Icons.person,
                                      size: isMobile ? 40 : 50,
                                      color: AppTheme.secondaryLight,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    // Icono de cámara para indicar que se puede cambiar la foto
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.primaryDark,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16),
                // Información del usuario
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _isEditing
                          ? TextFormField(
                              initialValue: usuario.nombreUsuario,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.secondaryLight,
                                fontSize: isMobile ? 20 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                hintText: 'Nombre de usuario',
                                hintStyle: TextStyle(
                                  color: AppTheme.secondaryLight.withOpacity(0.5),
                                ),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                // Guardaremos este valor cuando se guarden los cambios
                                _nombreUsuarioController = value;
                              },
                            )
                          : Text(
                              usuario.nombreUsuario,
                              style: GoogleFonts.montserrat(
                                color: AppTheme.secondaryLight,
                                fontSize: isMobile ? 22 : 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: AppTheme.accentBlue,
                            size: isMobile ? 18 : 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Nivel: ${usuario.nivelUsuario ?? "Novato"}',
                            style: GoogleFonts.inter(
                              color: AppTheme.accentBlue,
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Miembro desde ${_formatDate(usuario.fechaRegistro)}',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withOpacity(0.7),
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Biografía
            if (_isEditing)
              TextField(
                controller: _biografiaController..text = usuario.biografia ?? '',
                style: GoogleFonts.inter(
                  color: AppTheme.secondaryLight,
                ),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Biografía',
                  labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.accentBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppTheme.accentBlue, width: 2),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.secondaryDark.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.accentBlue,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Biografía',
                          style: GoogleFonts.montserrat(
                            color: AppTheme.accentBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      usuario.biografia?.isNotEmpty == true
                          ? usuario.biografia!
                          : 'Sin biografía. Edita tu perfil para añadir información sobre ti.',
                      style: GoogleFonts.inter(
                        color: AppTheme.secondaryLight.withOpacity(0.8),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isMobile ? 16 : 24),
            // Estadísticas rápidas
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

  String _formatDate(DateTime date) {
    final months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  Widget _construirTabBar() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          labelColor: AppTheme.accentBlue,
          unselectedLabelColor: AppTheme.secondaryLight.withOpacity(0.7),
          indicatorColor: AppTheme.accentBlue,
          indicatorWeight: 3,
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
    return Container(
      color: AppTheme.primaryDark,
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _construirSeccionEstadisticas(usuario),
          SizedBox(height: 24),
          _construirSeccionActividad(usuario),
        ],
      ),
    );
  }

  Widget _construirTabJuegos(UsuarioModelo usuario) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final crossAxisCount = isMobile ? 2 : 3;

    if (usuario.juegosRecientes.isEmpty) {
      return _buildEmptyState(
        'No has agregado ningún juego todavía',
        'Explora juegos y agrégalos a tu colección para verlos aquí',
        Icons.videogame_asset_outlined,
      );
    }

    return Container(
      color: AppTheme.primaryDark,
      child: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: usuario.juegosRecientes.length,
        itemBuilder: (context, index) {
          return _construirTarjetaJuego(usuario.juegosRecientes[index]);
        },
      ),
    );
  }

  Widget _construirTabLogros(UsuarioModelo usuario) {
    // Por ahora mostramos un estado vacío, en una implementación real se cargarían los logros
    return _buildEmptyState(
      'Aún no tienes logros desbloqueados',
      'Completa objetivos en tus juegos para conseguir logros',
      Icons.emoji_events_outlined,
    );
  }

  Widget _construirTabListas(UsuarioModelo usuario) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (usuario.listas.isEmpty) {
      // Si no hay listas, mostramos un estado vacío
      return Stack(
        children: [
          _buildEmptyState(
            'No has creado ninguna lista',
            'Crea listas personalizadas para organizar tus juegos',
            Icons.list_alt_outlined,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: AppTheme.accentBlue,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: _mostrarDialogoNuevaLista,
            ),
          ),
        ],
      );
    }

    // Si hay listas, las mostramos
    return Stack(
      children: [
        Container(
          color: AppTheme.primaryDark,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: usuario.listas.length,
            itemBuilder: (context, index) {
              final lista = usuario.listas[index];
              return Card(
                color: AppTheme.secondaryDark.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppTheme.accentBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                elevation: 0,
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Icon(
                        lista.esPrivada ? Icons.lock : Icons.public,
                        color: lista.esPrivada ? Colors.red : Colors.green,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        lista.nombre,
                        style: GoogleFonts.montserrat(
                          color: AppTheme.secondaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    '${lista.juegos.length} juegos • Creada el ${_formatDate(lista.fechaCreacion)}',
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: AppTheme.accentBlue,
                          size: 20,
                        ),
                        onPressed: () => _editarLista(lista),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () => _confirmarEliminarLista(lista),
                      ),
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lista.descripcion.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Descripción:',
                                  style: GoogleFonts.inter(
                                    color: AppTheme.accentBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  lista.descripcion,
                                  style: GoogleFonts.inter(
                                    color: AppTheme.secondaryLight.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                          lista.juegos.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: Text(
                                      'No hay juegos en esta lista',
                                      style: GoogleFonts.inter(
                                        color: AppTheme.secondaryLight.withOpacity(0.5),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                )
                              : _construirListaJuegos(lista.juegos, isMobile),
                          SizedBox(height: 8),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () => _agregarJuegoALista(lista),
                              icon: Icon(Icons.add_circle_outline, size: 18),
                              label: Text('Añadir Juego'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.accentBlue,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: AppTheme.accentBlue,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: _mostrarDialogoNuevaLista,
          ),
        ),
      ],
    );
  }

  Widget _construirListaJuegos(List<GameInList> juegos, bool isMobile) {
    return Container(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: juegos.length,
        itemBuilder: (context, index) {
          final juego = juegos[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: 12),
            child: Card(
              color: AppTheme.secondaryDark.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () => context.go('/game-details/${juego.gameId}'),
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen del juego
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      child: Container(
                        height: 85,
                        width: double.infinity,
                        child: juego.imagenUrl != null && juego.imagenUrl!.isNotEmpty
                            ? Image.network(
                                juego.imagenUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppTheme.secondaryDark,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: AppTheme.secondaryLight.withOpacity(0.5),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: AppTheme.secondaryDark,
                                child: Icon(
                                  Icons.videogame_asset,
                                  color: AppTheme.secondaryLight.withOpacity(0.5),
                                ),
                              ),
                      ),
                    ),
                    // Título del juego
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            juego.nombre,
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Añadido el ${_formatDate(juego.fechaAgregado)}',
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryLight.withOpacity(0.6),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.secondaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Crear Nueva Lista',
                style: GoogleFonts.montserrat(
                  color: AppTheme.secondaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      style: TextStyle(color: AppTheme.secondaryLight),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la lista',
                        labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue, width: 2),
                        ),
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
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Lista Privada',
                          style: TextStyle(color: AppTheme.secondaryLight),
                        ),
                        Spacer(),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nombreController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El nombre de la lista no puede estar vacío'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    
                    // Usar el ViewModel para crear la lista
                    final resultado = await _userViewModel.crearLista(
                      nombre: nombreController.text.trim(),
                      descripcion: descripcionController.text.trim(),
                      esPrivada: esPrivada,
                    );

                    if (resultado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lista creada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear la lista: ${_userViewModel.errorMessage}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  
  void _editarLista(GameList lista) {
    final TextEditingController nombreController = TextEditingController(text: lista.nombre);
    final TextEditingController descripcionController = TextEditingController(text: lista.descripcion);
    bool esPrivada = lista.esPrivada;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.secondaryDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Editar Lista',
                style: GoogleFonts.montserrat(
                  color: AppTheme.secondaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      style: TextStyle(color: AppTheme.secondaryLight),
                      decoration: InputDecoration(
                        labelText: 'Nombre de la lista',
                        labelStyle: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue, width: 2),
                        ),
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
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.accentBlue, width: 2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Lista Privada',
                          style: TextStyle(color: AppTheme.secondaryLight),
                        ),
                        Spacer(),
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nombreController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('El nombre de la lista no puede estar vacío'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    Navigator.pop(context);
                    
                    // Usar el ViewModel para actualizar la lista
                    final resultado = await _userViewModel.actualizarLista(
                      listaId: lista.id,
                      nombre: nombreController.text.trim(),
                      descripcion: descripcionController.text.trim(),
                      esPrivada: esPrivada,
                    );

                    if (resultado) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lista actualizada con éxito'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al actualizar la lista: ${_userViewModel.errorMessage}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmarEliminarLista(GameList lista) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Eliminar Lista',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar la lista "${lista.nombre}"? Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.secondaryLight.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Usar el ViewModel para eliminar la lista
              final resultado = await _userViewModel.eliminarLista(lista.id);

              if (resultado) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lista eliminada con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar la lista: ${_userViewModel.errorMessage}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
  
  void _agregarJuegoALista(GameList lista) {
    // En una implementación real, aquí mostrarías un diálogo o navegarías a una pantalla
    // para buscar y seleccionar juegos. Por ahora, mostraremos un diálogo simple.
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Añadir Juego a la Lista',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: AppTheme.accentBlue,
            ),
            SizedBox(height: 16),
            Text(
              'Esta funcionalidad se implementará próximamente. Podrás buscar y agregar juegos a tus listas personalizadas.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentBlue,
              foregroundColor: Colors.white,
            ),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _construirSeccionEstadisticas(UsuarioModelo usuario) {
    return Card(
      color: AppTheme.secondaryDark.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.accentBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: AppTheme.accentBlue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Estadísticas',
                  style: GoogleFonts.montserrat(
                    color: AppTheme.secondaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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

  Widget _construirSeccionActividad(UsuarioModelo usuario) {
    return Card(
      color: AppTheme.secondaryDark.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.accentBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.accentBlue,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Actividad Reciente',
                  style: GoogleFonts.montserrat(
                    color: AppTheme.secondaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Actividad simulada - En una implementación real se cargaría de la base de datos
            _construirItemActividad(
              'Te has unido a TRAKR',
              _formatDate(usuario.fechaRegistro),
              Icons.celebration,
            ),
            if (usuario.juegosRecientes.isNotEmpty)
              _construirItemActividad(
                'Has añadido un nuevo juego a tu colección',
                'Hace 2 días',
                Icons.videogame_asset,
              ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemActividad(String titulo, String fecha, IconData icono) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono,
              color: AppTheme.accentBlue,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  fecha,
                  style: GoogleFonts.inter(
                    color: AppTheme.secondaryLight.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirContador(String titulo, int cantidad) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.secondaryDark.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.accentBlue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              cantidad.toString(),
              style: GoogleFonts.montserrat(
                color: AppTheme.secondaryLight,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          titulo,
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight.withOpacity(0.7),
            fontSize: 14,
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
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icono, 
              color: AppTheme.accentBlue,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
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

  Widget _construirTarjetaJuego(String juego) {
    // En una implementación real, se cargaría la información del juego desde la API
    return GestureDetector(
      onTap: () {
        context.go('/game-details/3328'); // ID de juego simulado
      },
      child: Card(
        color: AppTheme.secondaryDark.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del juego (simulada)
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark,
                  image: DecorationImage(
                    image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/flutter-web-app-80ca6.appspot.com/o/placeholder-game.jpg?alt=media'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    juego,
                    style: GoogleFonts.inter(
                      color: AppTheme.secondaryLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.5',
                        style: GoogleFonts.inter(
                          color: AppTheme.secondaryLight.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Función para elegir imagen de perfil
  Future<void> _seleccionarImagenPerfil() async {
    // Aquí implementarías la lógica para seleccionar una imagen
    // En Web utilizarías html.FileUploadInputElement()
    // En móvil utilizarías image_picker
    
    // Para la demo, mostramos un diálogo indicando que está en desarrollo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Cambiar Imagen de Perfil',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: AppTheme.accentBlue,
            ),
            SizedBox(height: 16),
            Text(
              'Esta funcionalidad se implementará próximamente.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Aceptar',
              style: GoogleFonts.inter(
                color: AppTheme.accentBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Función para elegir imagen de banner
  Future<void> _seleccionarImagenBanner() async {
    // Similar a la función para seleccionar imagen de perfil
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.secondaryDark,
        title: Text(
          'Cambiar Banner',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction,
              size: 48,
              color: AppTheme.accentBlue,
            ),
            SizedBox(height: 16),
            Text(
              'Esta funcionalidad se implementará próximamente.',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Aceptar',
              style: GoogleFonts.inter(
                color: AppTheme.accentBlue,
              ),
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
        title: Text(
          'Cerrar Sesión',
          style: GoogleFonts.montserrat(
            color: AppTheme.secondaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '¿Estás seguro de que deseas cerrar sesión?',
          style: GoogleFonts.inter(
            color: AppTheme.secondaryLight.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(
              'Cerrar Sesión',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
              ),
            ),
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

  // Método para mostrar estado vacío
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.accentBlue.withOpacity(0.5),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.montserrat(
                color: AppTheme.secondaryLight,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: AppTheme.secondaryLight.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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