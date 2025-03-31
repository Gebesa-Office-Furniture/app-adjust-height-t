import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:controller/src/controllers/settings/theme_controller.dart';
import 'package:provider/provider.dart';

class BackgroundBlur extends StatelessWidget {
  const BackgroundBlur({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    var themeController = Provider.of<ThemeController>(context);
    var screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Fondo de color con blur
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),

        //only if theme is dark
        if (themeController.themeMode == ThemeMode.dark)
          // Circulo superior izquierdo
          Positioned(
            top: 10,
            left: -200,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: screenSize.width + 80,
                height: screenSize.width + 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
            ),
          ),

        if (themeController.themeMode == ThemeMode.dark)
          // Circulo inferior derecho
          Positioned(
            bottom: -80,
            right: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                ),
              ),
            ),
          ),

        if (themeController.themeMode == ThemeMode.dark)
          // Blur para el fondo
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              //scaffold background
              color: Theme.of(context)
                  .scaffoldBackgroundColor
                  .withOpacity(0.7), // Transparente para ver el blur
              // Transparente para ver el blur
            ),
          ),

        child,
      ],
    );
  }
}
