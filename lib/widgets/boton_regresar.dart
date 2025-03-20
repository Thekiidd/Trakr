import 'package:flutter/material.dart';

class BotonRegresar extends StatelessWidget {
  final String? titulo;
  final VoidCallback? alPresionar;
  final Color? colorIcono;

  const BotonRegresar({
    Key? key,
    this.titulo,
    this.alPresionar,
    this.colorIcono,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: colorIcono ?? Theme.of(context).primaryColor,
          ),
          onPressed: alPresionar ?? () => Navigator.of(context).pop(),
        ),
        if (titulo != null)
          Text(
            titulo!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorIcono ?? Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }
} 