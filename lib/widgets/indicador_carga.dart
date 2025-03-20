import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class IndicadorCarga extends StatelessWidget {
  final String? mensaje;
  final double tamano;
  final Color? color;

  const IndicadorCarga({
    Key? key,
    this.mensaje,
    this.tamano = 40.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitDoubleBounce(
            color: color ?? Theme.of(context).primaryColor,
            size: tamano,
          ),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(
              mensaje!,
              style: TextStyle(
                color: color ?? Theme.of(context).primaryColor,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class ContenedorCarga extends StatelessWidget {
  final bool estaCargando;
  final Widget hijo;
  final String? mensajeCarga;

  const ContenedorCarga({
    Key? key,
    required this.estaCargando,
    required this.hijo,
    this.mensajeCarga,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        hijo,
        if (estaCargando)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: IndicadorCarga(
              mensaje: mensajeCarga,
            ),
          ),
      ],
    );
  }
} 