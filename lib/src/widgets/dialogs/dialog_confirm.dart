//dialog confirm

import 'package:flutter/material.dart';

class DialogConfirm extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final Function onConfirm;
  final Function onCancel;
  final IconData? icon;
  final Color? iconColor;

  const DialogConfirm({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
    required this.onConfirm,
    required this.onCancel,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: icon != null ? Icon(icon, color: iconColor) : null,
      title: Text(title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Airbnb',
          )),
      content: Text(
        content,
        style: const TextStyle(fontFamily: 'Airbnb'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
            Navigator.of(context).pop();
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
