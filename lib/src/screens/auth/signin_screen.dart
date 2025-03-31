import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:controller/src/widgets/buttons/google_signin_button.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../controllers/auth/auth_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool isPasswordVisible = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);
    return BackgroundBlur(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.signIn),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: SizedBox(
            height: MediaQuery.of(context).size.height *
                0.8, // Ajusta el tamaño manualmente
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.email,
                              style: TextStyle(
                                color: Theme.of(context).iconTheme.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.enterEmail,
                              ),
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                              ],
                              validator: (value) {
                                var regExp = RegExp(
                                    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterEmailValidation;
                                }
                                if (!regExp.hasMatch(value)) {
                                  return AppLocalizations.of(context)!
                                      .validateEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              AppLocalizations.of(context)!.password,
                              style: TextStyle(
                                color: Theme.of(context).iconTheme.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: passwordController,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                hintText:
                                    AppLocalizations.of(context)!.enterPassword,
                                //password visibility
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    !isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return AppLocalizations.of(context)!
                                      .enterPasswordValidation;
                                }
                                if (value.length < 6) {
                                  return AppLocalizations.of(context)!
                                      .validPassword;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                            RoundedButton(
                              text: AppLocalizations.of(context)!.signIn,
                              isLoading: authController.isLoading,
                              padding: false,
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                if (formKey.currentState!.validate()) {
                                  bool resp = await authController.login(
                                    emailController.text,
                                    passwordController.text,
                                    context,
                                  );

                                  if (resp) {
                                    Navigator.pushNamed(context, '/home');
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/account/change-password');
                                  },
                                  style: TextButton.styleFrom(
                                      elevation: 0, shadowColor: Colors.grey),
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .forgotPassword,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color))),
                            ),
                            const SizedBox(height: 20),
                            GoogleSignInButton(onPressed: () async {
                              await authController.signInWithGoogle(context);
                            }),
                            const SizedBox(height: 20),
                            if (Platform.isIOS)
                              SignInWithAppleButton(
                                height: 50,
                                borderRadius: BorderRadius.circular(100),
                                text: AppLocalizations.of(context)!
                                    .signInWithApple,
                                onPressed: () {
                                  authController.signInWithApple(context);
                                },
                              )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }
}
