import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'dart:convert'; // utf8, json, base64Url
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/settings/theme_controller.dart';
import '../../controllers/settings/language_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';   // ← nuevo
import '../../api/token_manager.dart';
import 'dart:developer' as dev;
import 'package:flutter_timezone/flutter_timezone.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});
  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  WebViewController? _controller;
  bool isLoading = true; // controla el estado del spinner

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  late final WebViewCookieManager _cookieManager = WebViewCookieManager();

  // Función para obtener el token JWT del servidor
  Future<String?> _getJwtToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(TokenManager.TOKEN_KEY);
  }

  Future<String?> _loadUUID() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('sUUID');
    if (uuid == null) {
      return 'noexiste';
    }
    return uuid;
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  Future<String?> _getTimezone() async {
    return  await FlutterTimezone.getLocalTimezone();
  }

  /// Detecta `.../https//`  ↔  añade el  ':'  que falta.
/// Si la URL no tiene esquema (`www.`) también antepone `https://`.
  Uri _repairUri(String original) {
    final exp = RegExp(r'^https?://[^/]+/https//');         // caso netlify
    if (exp.hasMatch(original)) {
      return Uri.parse(original.replaceFirst(exp, 'https://'));
    }
    if (!original.startsWith(RegExp(r'https?://'))) {        // caso “www.”
      return Uri.parse('https://$original');
    }
    return Uri.parse(original);
  }

  /// Abre la dirección en el navegador por defecto.
  Future<void> _launchExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir ${uri.toString()}')),
      );
    }
  }

  Future<void> _initWebView() async {
    await [Permission.microphone].request();

    // Get theme and language from providers
    final themeController =
        Provider.of<ThemeController>(context, listen: false);
    final languageController =
        Provider.of<LanguageController>(context, listen: false);

    // Determine theme parameter for URL
    String themeParam =
        themeController.themeMode == ThemeMode.dark ? 'dark' : 'light';

    // Determine language parameter for URL
    String langParam = languageController.currentLocale.languageCode;

    // Obtener el token JWT
    String? jwtToken = await _getJwtToken();
    String? uuid = await _loadUUID();
    int? userId = await _getUserId();
    String? timezone = await _getTimezone();

    // Generate URL with parameters
    String host = 'lucky-medovik-a419a7.netlify.app'; // ← sin “https://”
    String shUrl = 'https://$host/';
    String url = '$shUrl?lang=$langParam&theme=$themeParam';

    final ctrl = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setNavigationDelegate(
    NavigationDelegate(
      onNavigationRequest: (request) async {
        final fixed = _repairUri(request.url);

        // Si cambió o pertenece a otro dominio, sácalo de la WebView
        if (fixed.toString() != request.url ||
            !fixed.host.contains(host)) {                 // host = lucky-medovik...
          await _launchExternal(fixed);
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
      onPageStarted: (url) {
        setState(() => isLoading = true);
        _cookieManager.setCookie(WebViewCookie(
          name: 'jwt_token',
          value: '$jwtToken,,,,,$uuid,,,,,$userId,,,,,$timezone',
          domain: host,                                   // ← solo el dominio
        ));
      },
      onPageFinished: (_) => setState(() => isLoading = false),
    ),
  )
  ..loadRequest(Uri.parse(url));

    // callbacks específicos de plataforma …
    if (ctrl.platform is AndroidWebViewController) {
      final android = ctrl.platform as AndroidWebViewController;
      android
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) async {
          if (request.types
                  .contains(WebViewPermissionResourceType.microphone) ||
              request.types.contains(WebViewPermissionResourceType.camera)) {
            await request.grant();
          } else {
            await request.deny();
          }
        });
    }

    if (ctrl.platform is WebKitWebViewController) {
      final ios = ctrl.platform as WebKitWebViewController;
      ios.setOnPlatformPermissionRequest((request) async => request.grant());
    }

    setState(() => _controller = ctrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            child: _controller == null
                ? const SizedBox()
                : WebViewWidget(controller: _controller!),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.cyan,
              ),
            ),
        ],
      ),
    );
  }
}
