import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

class AgregarJuegoDialog extends StatefulWidget {
  final Map<String, dynamic> juego;

  const AgregarJuegoDialog({
    Key? key,
    required this.juego,
  }) : super(key: key);

  @override
  State<AgregarJuegoDialog> createState() => _AgregarJuegoDialogState();
}

class _AgregarJuegoDialogState extends State<AgregarJuegoDialog> {
  final _formKey = GlobalKey<FormState>();
  int _tiempoJugado = 0;
  double _rating = 0.0;
  String _estado = 'Jugando';
  String? _plataforma;
  final _notasController = TextEditingController();
  
  final List<String> _estados = ['Jugando', 'Completado', 'En pausa', 'Abandonado'];
  final List<String> _plataformas = ['PC', 'PS5', 'Xbox Series X|S', 'Nintendo Switch', 'Mobile', 'Otro'];

  @override
  void dispose() {
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.primaryDark,
      title: Text(
        'Agregar ${widget.juego['nombre']}',
        style: const TextStyle(color: Colors.white),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Estado del juego
              DropdownButtonFormField<String>(
                value: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: AppTheme.primaryDark,
                style: const TextStyle(color: Colors.white),
                items: _estados.map((String estado) {
                  return DropdownMenuItem<String>(
                    value: estado,
                    child: Text(estado),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _estado = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Plataforma
              DropdownButtonFormField<String>(
                value: _plataforma,
                decoration: const InputDecoration(
                  labelText: 'Plataforma',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                dropdownColor: AppTheme.primaryDark,
                style: const TextStyle(color: Colors.white),
                items: _plataformas.map((String plataforma) {
                  return DropdownMenuItem<String>(
                    value: plataforma,
                    child: Text(plataforma),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _plataforma = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Tiempo jugado
              TextFormField(
                initialValue: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Tiempo jugado (minutos)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _tiempoJugado = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Rating
              Row(
                children: [
                  const Text(
                    'Rating: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  Expanded(
                    child: Slider(
                      value: _rating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: _rating.toStringAsFixed(1),
                      onChanged: (double value) {
                        setState(() {
                          _rating = value;
                        });
                      },
                    ),
                  ),
                  Text(
                    _rating.toStringAsFixed(1),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notas
              TextFormField(
                controller: _notasController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop({
                'tiempoJugado': _tiempoJugado,
                'rating': _rating,
                'estado': _estado,
                'plataforma': _plataforma,
                'notas': _notasController.text,
              });
            }
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
} 