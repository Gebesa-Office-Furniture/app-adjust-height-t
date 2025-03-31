import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth/auth_controller.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);
    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.changePassword),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(children: [
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.textChangePassword,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterEmail,
              ),
            ),
            const SizedBox(height: 20),
            RoundedButton(
              isLoading: authController.isLoading,
              text: "Send",
              onPressed: () async {
                await authController.sendPasswordResetEmail(
                    emailController.text, context);
                Navigator.pop(context);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
