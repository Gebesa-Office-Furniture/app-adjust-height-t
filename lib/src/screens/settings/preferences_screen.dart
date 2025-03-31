import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:controller/src/controllers/settings/language_controller.dart';
import 'package:controller/src/controllers/settings/theme_controller.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var themeController = Provider.of<ThemeController>(context);
    var languageController = Provider.of<LanguageController>(context);
    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.preferencesButton),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.darkMode,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              trailing: Switch(
                value: themeController.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  HapticFeedback.lightImpact();
                  themeController.toggleTheme(value);
                },
              ),
            ),
            //change language en/es
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Text(AppLocalizations.of(context)!.language,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    //grey splash

                    title: Text(AppLocalizations.of(context)!.english),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      languageController.changeLanguage('en');
                    },
                    trailing:
                        languageController.currentLocale.languageCode == 'en'
                            ? const Icon(Icons.check)
                            : null,
                  ),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text(AppLocalizations.of(context)!.spanish),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      languageController.changeLanguage('es');
                    },
                    trailing:
                        languageController.currentLocale.languageCode == 'es'
                            ? const Icon(Icons.check)
                            : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
