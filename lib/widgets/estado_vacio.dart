import 'package:flutter/material.dart';

class EstadoVacio extends StatelessWidget {
  final String titulo;
  final String? mensaje;
  final IconData? icono;
  final VoidCallback? alPresionarBoton;
  final String? textoBoton;

  const EstadoVacio({
    Key? key,
    required this.titulo,
    this.mensaje,
    this.icono,
    this.alPresionarBoton,
    this.textoBoton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icono != null)
              Icon(
                icono,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.5),
              ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (mensaje != null) ...[
              const SizedBox(height: 8),
              Text(
                mensaje!,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (alPresionarBoton != null && textoBoton != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: alPresionarBoton,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(textoBoton!),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 