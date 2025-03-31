import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:controller/src/controllers/routines/routine_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:controller/routes/app_routes.dart';
import 'package:controller/src/api/auth_api.dart';
import 'package:controller/src/api/error_handler.dart';
import 'package:controller/src/api/token_manager.dart';
import 'package:controller/src/data/models/user.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../routes/settings_routes.dart';
import '../../widgets/toast_service.dart';

class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Estado del usuario
  User? _firebaseUser;
  UserModel? _userInfo;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _token;

  bool get isLoading => _isLoading;
  User? get firebaseUser => _firebaseUser;
  UserModel? get userInfo => _userInfo;
  String? get token => _token;

  //notifications
  // Método para inicializar notificaciones
  Future<void> initializeNotifications(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Solicitar permisos
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos otorgados para las notificaciones push');

      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM Token: $token');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcmToken', token);
        prefs.setBool('notificationsEnabled', true);

        final response = await AuthApi.registerFcmToken(token);
        if (!response['success']) {
          print('Error al registrar el token FCM');
        } else {
          print('Token FCM registrado correctamente');
        }
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Mensaje recibido en primer plano: ${message.notification}');
        HapticFeedback.vibrate();
        context.read<RoutineController>().stopRoutine();
        ToastService.showInfo(context, message.notification!.title!,
            description: message.notification!.body!,
            alignment: Alignment.topCenter,
            duration: const Duration(seconds: 10));
      });

      //onMessageOpenedApp
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Mensaje recibido al abrir la app: ${message.notification}');
        HapticFeedback.vibrate();
        context.read<RoutineController>().stopRoutine();
        ToastService.showInfo(context, message.notification!.title!,
            description: message.notification!.body!,
            alignment: Alignment.topCenter,
            duration: const Duration(seconds: 2));
      });

      //onBackgroundMessage
      FirebaseMessaging.onBackgroundMessage(
          (message) => firebaseMessagingBackgroundHandler(message));
    } else {
      print('Permisos denegados para las notificaciones push');
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('notificationsEnabled', false);
    }
  }

  // Handler para mensajes en segundo plano
  Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Mensaje recibido en segundo plano: ${message.messageId}');
  }

  /// Actualiza el estado de `isLoading` y notifica
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Actualiza el estado de `_isDeleting` y notifica
  void _setDeleting(bool value) {
    _isDeleting = value;
    notifyListeners();
  }

  /// Carga los datos del usuario desde `SharedPreferences`
  Future<void> loadUserData() async {
    _firebaseUser = _auth.currentUser;
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    final email = prefs.getString('email');
    final id = prefs.getInt('id');
    final weight = prefs.getDouble('weight');
    final height = prefs.getDouble('height');
    _userInfo = UserModel(
        name: name, email: email, id: id, weight: weight, height: height);
    notifyListeners();
  }

  /// Guarda los datos del usuario en `SharedPreferences`
  Future<void> _saveUserData(UserResponse user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', user.user!.id!);
    await prefs.setString('name', user.user!.name!);
    await prefs.setString('email', user.user!.email!);
    await prefs.setDouble('weight', user.user!.weight ?? 0);
    await prefs.setDouble('height', user.user!.height ?? 0);
    await prefs.setInt('measurementUnit', user.user!.idMeasureType ?? 0);
    _userInfo = user.user;
    if (user.token != null && user.refreshToken != null) {
      await TokenManager.saveTokens(
        token: user.token!.result!,
        tokenExpiry: DateTime.now().add(
          Duration(seconds: user.token!.expiresIn!),
        ),
        refreshToken: user.refreshToken!.result!,
        refreshTokenExpiry: DateTime.now().add(
          Duration(seconds: user.refreshToken!.expiresIn!),
        ),
      );
    }

    if (user.user!.objMemories != null) {
      List<ObjMemory> memories = user.user!.objMemories!;
      for (int i = 0; i < memories.length; i++) {
        if (memories[i].iOrder != null && memories[i].dHeightInch != null) {
          if (memories[i].iOrder == 1) {
            await prefs.setDouble('memory1', memories[i].dHeightInch!);
          }
          if (memories[i].iOrder == 2) {
            await prefs.setDouble('memory2', memories[i].dHeightInch!);
          }
          if (memories[i].iOrder == 3) {
            await prefs.setDouble('memory3', memories[i].dHeightInch!);
          }
        }
      }
    }

    if (user.user!.objRoutine != null) {
      ObjRoutine routine = user.user!.objRoutine!;
      await prefs.setInt('routineId', routine.iId!);
      await prefs.setInt('routineDuration', routine.iDurationSecondsTarget!);
      await prefs.setString(
          'routineStartTime', routine.dtStartDate!.toIso8601String());
    }

    if (user.user!.lastRoutine != null) {
      LastRoutine routine = user.user!.lastRoutine!;
      await prefs.setInt('routineId', routine.iId!);
      await prefs.setInt('routineDuration', routine.iDurationSeconds!);
    }
    notifyListeners();
  }

  //update name
  Future<void> updateName(String name) async {
    _userInfo!.name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    notifyListeners();
  }

  /// Borra los datos del usuario de `SharedPreferences`
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _userInfo = null;
    _firebaseUser = null;
    notifyListeners();
  }

  /// Registro con email y contraseña en Firebase
  Future<bool> signUp(
      String email, String password, String name, BuildContext context) async {
    try {
      _setLoading(true);
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final response =
          await AuthApi.registerUser(name, email, userCredential.user!.uid);

      if (response['success']) {
        _firebaseUser = userCredential.user;
        await _auth.currentUser!.updateDisplayName(name);
        UserResponse userResponse = userResponseFromJson(response['data']);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("newUser", true);
        await _saveUserData(userResponse);
        return true;
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
        userCredential.user!.delete();
        return false;
      }
    } on FirebaseAuthException catch (e) {
      ToastService.showError(
          context, _firebaseAuthErrorMessage(e.code, context));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Inicio de sesión con email y contraseña en Firebase
  Future<bool> login(
      String email, String password, BuildContext context) async {
    try {
      _setLoading(true);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verificar información en base de datos
      var response = await AuthApi.loginUser(email, userCredential.user!.uid);
      if (response['success']) {
        log(response['data'].toString());
        _firebaseUser = userCredential.user;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("newUser", false);
        UserResponse userResponse = userResponseFromJson(response['data']);
        print(response['data']);
        _userInfo = userResponse.user;
        await _saveUserData(userResponse);
        notifyListeners();
        return true;
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);

        return false;
      }
    } on FirebaseAuthException catch (e) {
      ToastService.showError(
          context, _firebaseAuthErrorMessage(e.code, context));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  //sign in with google package
  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      _setLoading(true);
      GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        UserCredential userCredential =
            await _auth.signInWithCredential(GoogleAuthProvider.credential(
          idToken: (await googleUser.authentication).idToken,
          accessToken: (await googleUser.authentication).accessToken,
        ));

        if (userCredential.user == null) {
          return false;
        }

        //if user is not registered
        if (userCredential.additionalUserInfo!.isNewUser) {
          final response = await AuthApi.registerUser(
              googleUser.displayName ?? googleUser.email,
              googleUser.email,
              googleUser.id);

          if (response['success']) {
            UserResponse userResponse = userResponseFromJson(response['data']);
            await _saveUserData(userResponse);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("newUser", true);
            Navigator.pushNamedAndRemoveUntil(
                context, SettingsRoutes.tutorial, (route) => false);

            return true;
          } else {
            ToastService.showError(
                context,
                response['type'] != null
                    ? ErrorHandler.getErrorMessage(response['type'], context)
                    : json.decode(response['error'])['message']);
            return false;
          }
        } else {
          //if user is already registered
          final response =
              await AuthApi.loginUser(googleUser.email, googleUser.id);

          if (response['success']) {
            UserResponse userResponse = userResponseFromJson(response['data']);
            print(response['data']);
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("newUser", false);
            await _saveUserData(userResponse);
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.home, (route) => false);
            return true;
          } else {
            ToastService.showError(
                context,
                response['type'] != null
                    ? ErrorHandler.getErrorMessage(response['type'], context)
                    : json.decode(response['error'])['message']);
            return false;
          }
        }
      } else {
        return false;
      }
    } finally {
      _setLoading(false);
    }
  }

  //apple sign in
  Future<bool> signInWithApple(BuildContext context) async {
    try {
      _setLoading(true);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        return false;
      }

      final identityToken = appleCredential.identityToken;
      String? email;

      //if user is not registered
      if (userCredential.additionalUserInfo!.isNewUser) {
        if (identityToken != null) {
          final data = JwtDecoder.decode(identityToken);
          email = data['email'] as String?;
        }

        final response = await AuthApi.registerUser(
            appleCredential.givenName ?? email!.split('@').first,
            email ?? appleCredential.email!,
            appleCredential.userIdentifier!);

        if (response['success']) {
          UserResponse userResponse = userResponseFromJson(response['data']);
          await _saveUserData(userResponse);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("newUser", true);
          Navigator.pushNamedAndRemoveUntil(
              context, SettingsRoutes.tutorial, (route) => false);
          return true;
        } else {
          ToastService.showError(
              context,
              response['type'] != null
                  ? ErrorHandler.getErrorMessage(response['type'], context)
                  : json.decode(response['error'])['message']);
          return false;
        }
      } else {
        if (identityToken != null) {
          final data = JwtDecoder.decode(identityToken);
          email = data['email'] as String?;
        }
        //if user is already registered
        final response = await AuthApi.loginUser(
            email ?? appleCredential.email!, appleCredential.userIdentifier!);

        if (response['success']) {
          UserResponse userResponse = userResponseFromJson(response['data']);
          await _saveUserData(userResponse);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool("newUser", false);
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.home, (route) => false);
          return true;
        } else {
          ToastService.showError(
              context,
              response['type'] != null
                  ? ErrorHandler.getErrorMessage(response['type'], context)
                  : json.decode(response['error'])['message']);
          return false;
        }
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    await _clearUserData();
    await _auth.signOut();
  }

  /// Cambiar el nombre del usuario
  Future<void> changeName(String newName, BuildContext context) async {
    try {
      _setLoading(true);
      await _auth.currentUser!.updateDisplayName(newName);
      final response = await AuthApi.updateUserName(newName);

      if (response['success']) {
        await updateName(newName);
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Enviar correo para restablecer contraseña
  Future<void> sendPasswordResetEmail(
      String email, BuildContext context) async {
    try {
      _setLoading(true);
      await _auth.sendPasswordResetEmail(email: email);
      ToastService.showSuccess(
          context, AppLocalizations.of(context)!.resetPasswordEmailSent);
    } on FirebaseAuthException catch (e) {
      ToastService.showError(
          context, _firebaseAuthErrorMessage(e.code, context));
    } finally {
      _setLoading(false);
    }
  }

  //Delete account
  Future<bool> deleteAccount(BuildContext context) async {
    try {
      _setDeleting(true);
      final response = await AuthApi.deleteAccount();

      if (response['success']) {
        return true;
      } else {
        ToastService.showError(
            context,
            response['type'] != null
                ? ErrorHandler.getErrorMessage(response['type'], context)
                : json.decode(response['error'])['message']);
        return false;
      }
    } finally {
      _setDeleting(false);
    }
  }

  /// Manejo de errores de Firebase Auth
  String _firebaseAuthErrorMessage(String code, BuildContext context) {
    switch (code) {
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.emailAlreadyInUse;
      case 'network-request-failed':
        return AppLocalizations.of(context)!.socketException;
      case 'wrong-password':
        return AppLocalizations.of(context)!.wrongPassword;
      case 'user-not-found':
        return AppLocalizations.of(context)!.userNotFound;
      case 'weak-password':
        return AppLocalizations.of(context)!.weakPassword;
      case 'INVALID_LOGIN_CREDENTIALS':
        return AppLocalizations.of(context)!.invalidLoginCredentials;
      case 'invalid-credential':
        return AppLocalizations.of(context)!.invalidLoginCredentials;
      case 'too-many-requests':
        return AppLocalizations.of(context)!.toManyRequests;
      default:
        return AppLocalizations.of(context)!.unknownException;
    }
  }
}
