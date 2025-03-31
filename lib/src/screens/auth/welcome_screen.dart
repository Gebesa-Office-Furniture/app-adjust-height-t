import 'package:flutter/material.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/buttons/buttons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Builder(builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/brand/home_image.jpg',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Theme.of(context).scaffoldBackgroundColor,
                            Colors.black.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(AppLocalizations.of(context)!.welcome,
                            style: TextStyle(
                              color: Theme.of(context).iconTheme.color,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/brand/logo_splash.png',
                              height: 20,
                              fit: BoxFit.cover,
                            ),
                            const Text(" App",
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    RoundedButton(
                      text: AppLocalizations.of(context)!.signUp,
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                    ),
                    const SizedBox(height: 20),
                    RoundedButton(
                      text: AppLocalizations.of(context)!.signIn,
                      white: true,
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.of(context)!.termsAndConditions,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
