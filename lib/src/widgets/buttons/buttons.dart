//elevated button widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/settings/theme_controller.dart';

class PrincipalButton extends StatelessWidget {
  const PrincipalButton({super.key, this.text, this.onPressed});

  final String? text;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    var sc = MediaQuery.of(context).size;
    return SizedBox(
      width: sc.width * 0.7,
      child: ElevatedButton(
        style: ElevatedButtonTheme.of(context).style,
        onPressed: onPressed,
        child: Text(text!,
            style: const TextStyle(
                fontSize: 18, color: Colors.white, fontFamily: 'Airbnb')),
      ),
    );
  }
}

//rounded button widget
class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    this.text,
    this.onPressed,
    this.white = false,
    this.isLoading = false,
    this.padding = true,
  });

  final String? text;
  final Function()? onPressed;
  final bool white;
  final bool padding;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    var themeController = Provider.of<ThemeController>(context);
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding ? 20 : 0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.grey,
            backgroundColor: onPressed != null
                ? white
                    ? Colors.white
                    : Theme.of(context).primaryColor
                : Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
              side: white
                  ? BorderSide(
                      color: themeController.themeMode == ThemeMode.light
                          ? Theme.of(context).primaryColor
                          : Colors.white,
                    )
                  : BorderSide.none,
            ),
            shadowColor: onPressed != null
                ? white
                    ? Colors.grey
                    : Theme.of(context).primaryColorLight
                : Colors.grey,
          ),
          onPressed: onPressed,
          child: !isLoading
              ? Text(
                  text!,
                  style: TextStyle(
                      color: !white ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Airbnb'),
                )
              : const SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
        ),
      ),
    );
  }
}
