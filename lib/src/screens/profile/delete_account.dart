import 'dart:io';
import 'package:controller/src/widgets/toast_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../controllers/auth/auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({Key? key}) : super(key: key);

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  bool _isDeleting = false;

  Future<void> promptForPasswordAndDelete(BuildContext context) async {
    var authController = context.read<AuthController>();
    final user = FirebaseAuth.instance.currentUser;
    final providerData = user?.providerData.first;

    if (providerData != null) {
      if (providerData.providerId == EmailAuthProvider.PROVIDER_ID) {
        // El usuario inició sesión con email y contraseña
        final email = user?.email;
        if (email != null) {
          final passwordController = TextEditingController();
          //delay to close dialog

          // Mostrar diálogo para pedir la contraseña
          await showDialog(
            context: context,
            builder: (context) {
              //key
              GlobalKey<FormState> formKey = GlobalKey<FormState>();
              return Form(
                key: formKey,
                child: AlertDialog(
                  title: Text(AppLocalizations.of(context)!.reauthenticate),
                  content: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppLocalizations.of(context)!
                            .enterPasswordValidation;
                      }
                      return null;
                    },
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.enterPassword),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final credential = EmailAuthProvider.credential(
                              email: email,
                              password: passwordController.text,
                            );
                            await user
                                ?.reauthenticateWithCredential(credential);
                            _isDeleting = true;
                            setState(() {});
                            await user?.delete();
                            await authController.deleteAccount(context);

                            _isDeleting = false;
                            setState(() {});
                          } on FirebaseAuthException catch (e) {
                            handleFirebaseAuthError(context, e.code);
                          } catch (e) {
                            ToastService.showError(
                                context, 'An unexpected error occurred.');
                          }
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      } else if (providerData.providerId == GoogleAuthProvider.PROVIDER_ID) {
        // El usuario inició sesión con Google
        try {
          final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
          final GoogleSignInAuthentication googleAuth =
              await googleUser!.authentication;

          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await user?.reauthenticateWithCredential(credential);
          _isDeleting = true;
          setState(() {});
          await user?.delete();
          await authController.deleteAccount(context);
          _isDeleting = false;
          setState(() {});
        } catch (e) {
          setState(() {
            _isDeleting = false;
          });
          print("Error reauthenticating with Google: $e");
        }
      } else if (providerData.providerId == "apple.com") {
        // El usuario inició sesión con Apple
        try {
          final appleCredential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          final oauthCredential = OAuthProvider("apple.com").credential(
            idToken: appleCredential.identityToken,
            accessToken: appleCredential.authorizationCode,
          );
          await user?.reauthenticateWithCredential(oauthCredential);
          _isDeleting = true;
          setState(() {});
          await user?.delete();
          await authController.deleteAccount(context);
          _isDeleting = false;
          setState(() {});
        } catch (e) {
          setState(() {
            _isDeleting = false;
          });
          print("Error reauthenticating with Apple: $e");
        }
      } else {
        // Otros proveedores
        print(
            "Provider ${providerData.providerId} no soportado para reautenticación.");
      }
    } else {
      print("No se encontró información del proveedor.");
    }
  }

  void handleFirebaseAuthError(BuildContext context, String errorCode) {
    String errorMessage;

    switch (errorCode) {
      case 'invalid-credential':
        errorMessage = 'The provided credential is invalid. Please try again.';
        break;
      case 'wrong-password':
        errorMessage = 'The password is incorrect. Please check and try again.';
        break;
      default:
        errorMessage = 'An unknown error occurred. Please try again later.';
    }

    // Muestra el mensaje con el servicio de Toast
    ToastService.showError(context, errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context)!.deleteAccount),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 80, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.deleteAccountTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.deleteAccountDescription,
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: () {
                        Navigator.pop(
                            context); // Regresa a la pantalla anterior
                      },
                      child: Text(AppLocalizations.of(context)!.cancel,
                          style: const TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () async {
                        HapticFeedback.mediumImpact();
                        await promptForPasswordAndDelete(context);
                      },
                      child: Text(AppLocalizations.of(context)!.deleteAccount,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        if (_isDeleting)
          Container(
            color: Colors.black.withOpacity(.6),
            child: Center(
              child: Platform.isIOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
