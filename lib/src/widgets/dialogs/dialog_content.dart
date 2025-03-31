//dialog with widget

import 'package:flutter/material.dart';

class DialogContent extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final Function onConfirm;
  final String cancelText;
  final Function onCancel;

  const DialogContent({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.onConfirm,
    required this.cancelText,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(0),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontFamily: 'Airbnb', fontSize: 16)),
      content: content,
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
