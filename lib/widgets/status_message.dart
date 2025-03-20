import 'package:flutter/material.dart';

// Cambiar de TipoMensaje a MessageType
enum MessageType {
  error,
  success,
  warning,
  info,
}

// Cambiar de MensajeEstado a StatusMessage
class StatusMessage extends StatelessWidget {
  final String message;
  final MessageType type;
  final VoidCallback? onClose;
  final Duration duration;
  final bool showIcon;

  const StatusMessage({
    Key? key,
    required this.message,
    this.type = MessageType.info,
    this.onClose,
    this.duration = const Duration(seconds: 4),
    this.showIcon = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getColor(context).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            if (showIcon) ...[
              Icon(_getIcon(), color: _getColor(context)),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: _getColor(context)),
              ),
            ),
            if (onClose != null)
              IconButton(
                icon: Icon(Icons.close, color: _getColor(context)),
                onPressed: onClose,
              ),
          ],
        ),
      ),
    );
  }

  Color _getColor(BuildContext context) {
    switch (type) {
      case MessageType.error:
        return Colors.red;
      case MessageType.success:
        return Colors.green;
      case MessageType.warning:
        return Colors.orange;
      case MessageType.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (type) {
      case MessageType.error:
        return Icons.error_outline;
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.warning:
        return Icons.warning_amber_rounded;
      case MessageType.info:
        return Icons.info_outline;
    }
  }
}

// Cambiar de mostrarMensaje a showMessage
void showMessage({
  required BuildContext context,
  required String message,
  MessageType type = MessageType.info,
  Duration duration = const Duration(seconds: 4),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: StatusMessage(
        message: message,
        type: type,
        duration: duration,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    ),
  );
} 