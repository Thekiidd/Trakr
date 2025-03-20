import 'package:flutter/material.dart';

enum TipoMensaje {
  error,
  exito,
  advertencia,
  info,
}

class MensajeEstado extends StatelessWidget {
  final String mensaje;
  final TipoMensaje tipo;
  final VoidCallback? alPresionarCerrar;
  final Duration duracion;
  final bool mostrarIcono;

  const MensajeEstado({
    Key? key,
    required this.mensaje,
    this.tipo = TipoMensaje.info,
    this.alPresionarCerrar,
    this.duracion = const Duration(seconds: 4),
    this.mostrarIcono = true,
  }) : super(key: key);

  Color _obtenerColor(BuildContext context) {
    switch (tipo) {
      case TipoMensaje.error:
        return Colors.red.shade700;
      case TipoMensaje.exito:
        return Colors.green.shade700;
      case TipoMensaje.advertencia:
        return Colors.orange.shade700;
      case TipoMensaje.info:
        return Colors.blue.shade700;
    }
  }

  IconData _obtenerIcono() {
    switch (tipo) {
      case TipoMensaje.error:
        return Icons.error_outline;
      case TipoMensaje.exito:
        return Icons.check_circle_outline;
      case TipoMensaje.advertencia:
        return Icons.warning_amber_outlined;
      case TipoMensaje.info:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _obtenerColor(context).withOpacity(0.1),
          border: Border.all(
            color: _obtenerColor(context).withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            if (mostrarIcono) ...[
              Icon(
                _obtenerIcono(),
                color: _obtenerColor(context),
                size: 24,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(
                  color: _obtenerColor(context),
                  fontSize: 14,
                ),
              ),
            ),
            if (alPresionarCerrar != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: _obtenerColor(context),
                  size: 20,
                ),
                onPressed: alPresionarCerrar,
              ),
          ],
        ),
      ),
    );
  }
}

void mostrarMensaje({
  required BuildContext context,
  required String mensaje,
  TipoMensaje tipo = TipoMensaje.info,
  Duration duracion = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: MensajeEstado(
        mensaje: mensaje,
        tipo: tipo,
        duracion: duracion,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duracion,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
    ),
  );
} 