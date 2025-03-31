import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/routes/settings_routes.dart';
import 'package:controller/src/controllers/auth/auth_controller.dart';
import 'package:controller/src/widgets/backround_blur.dart';
import 'package:controller/src/widgets/buttons/buttons.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);

    return BackgroundBlur(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            AppLocalizations.of(context)!.signUp,
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.username,
                    style: TextStyle(
                      color: Theme.of(context).iconTheme.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterUsername,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9._-]')),
                    ],
                    validator: (value) {
                      // Validar que contenga solo los caracteres permitidos
                      var regExp = RegExp(r'^[a-zA-Z0-9._-]+$');
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!
                            .enterUsernameValidation;
                      }
                      if (!regExp.hasMatch(value)) {
                        return AppLocalizations.of(context)!
                            .enterNameValidation;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  //email
                  Text(
                    AppLocalizations.of(context)!.email2,
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
                      hintText: AppLocalizations.of(context)!.enterEmail,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                    validator: (value) {
                      var regExp =
                          RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!
                            .enterEmailValidation;
                      }
                      if (!regExp.hasMatch(value)) {
                        return AppLocalizations.of(context)!.validateEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.password2,
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
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.enterPassword,
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
                        return AppLocalizations.of(context)!.validPassword;
                      }
                      //match passwords
                      if (value != confirmPasswordController.text) {
                        return AppLocalizations.of(context)!
                            .passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context)!.confirmPassword,
                    style: TextStyle(
                      color: Theme.of(context).iconTheme.color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: !isPasswordVisible,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.confirmPassword,
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
                        return AppLocalizations.of(context)!.validPassword;
                      }
                      //match passwords
                      if (value != passwordController.text) {
                        return AppLocalizations.of(context)!
                            .passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  //expand the column
                  const SizedBox(height: 60),
                  RoundedButton(
                    text: AppLocalizations.of(context)!.signUp,
                    isLoading: authController.isLoading,
                    padding: false,
                    onPressed: authController.isLoading
                        ? null
                        : () async {
                            if (formKey.currentState!.validate()) {
                              bool resp = await authController.signUp(
                                emailController.text,
                                passwordController.text,
                                usernameController.text,
                                context,
                              );
                              if (resp) {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    SettingsRoutes.tutorial, (route) => false);
                              }
                            }
                          },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
