import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:file_picker/file_picker.dart';

import '../../controllers/settings/theme_controller.dart';
import '../../controllers/settings/language_controller.dart';
import '../../api/token_manager.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  InAppWebViewController? _controller;
  bool isLoading = true;
  final CookieManager _cookieManager = CookieManager.instance();

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  // ───────────────────── helpers ─────────────────────

  Future<String?> _getJwtToken() async =>
      (await SharedPreferences.getInstance()).getString(TokenManager.TOKEN_KEY);

  Future<String?> _loadUUID() async =>
      (await SharedPreferences.getInstance()).getString('sUUID') ?? 'noexiste';

  Future<int?> _getUserId() async =>
      (await SharedPreferences.getInstance()).getInt('id');

  Future<String?> _getTimezone() async =>
      await FlutterTimezone.getLocalTimezone();

  Uri _repairUri(String original) {
    final exp = RegExp(r'^https?://[^/]+/https//');
    if (exp.hasMatch(original)) {
      return Uri.parse(original.replaceFirst(exp, 'https://'));
    }
    if (!original.startsWith(RegExp(r'https?://'))) {
      return Uri.parse('https://$original');
    }
    return Uri.parse(original);
  }

  Future<void> _launchExternal(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir ${uri.toString()}')),
      );
    }
  }

  Future<void> _setPermissions() async {
    if (Platform.isIOS) {
      // Solicitar permisos de micrófono en iOS
      final microphoneStatus = await Permission.microphone.request();
      if (microphoneStatus != PermissionStatus.granted) {
        debugPrint('Microphone permission denied');
      }
      
      // También solicitar permiso de reconocimiento de voz si es necesario
      final speechStatus = await Permission.speech.request();
      if (speechStatus != PermissionStatus.granted) {
        debugPrint('Speech recognition permission denied');
      }
    }
  }

  // ───────────────────── WebView ─────────────────────

  Future<void> _initWebView() async {
    // Solicitar permisos antes de inicializar WebView
    await _setPermissions();
    
    // Tema e idioma
    final themeCtrl = Provider.of<ThemeController>(context, listen: false);
    final langCtrl = Provider.of<LanguageController>(context, listen: false);
    final themeParam = themeCtrl.themeMode == ThemeMode.dark ? 'dark' : 'light';
    final langParam = langCtrl.currentLocale.languageCode;

    // Datos para cookie
    final jwt = await _getJwtToken();
    final uuid = await _loadUUID();
    final userId = await _getUserId();
    final tz = await _getTimezone();

    // URL base
    const host = 'ubiquitous-mandazi-271500.netlify.app';
    final url = Uri.https(host, '/', {'lang': langParam, 'theme': themeParam});

    // Cookie antes de cargar la vista (requisito iOS)
    await _cookieManager.setCookie(
      url: WebUri(url.toString()),
      name: 'jwt_token',
      value: '$jwt,,,,,$uuid,,,,,$userId,,,,,$tz',
      domain: host,
      path: '/',
    );
  }

  // ───────────────────── UI ─────────────────────

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
            child: InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(
                  Uri.https(
                    'ubiquitous-mandazi-271500.netlify.app',
                    '/',
                    {
                      'lang': Provider.of<LanguageController>(context, listen: false).currentLocale.languageCode,
                      'theme': Provider.of<ThemeController>(context, listen: false).themeMode == ThemeMode.dark ? 'dark' : 'light',
                    },
                  ).toString(),
                ),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                allowsInlineMediaPlayback: true,
                mediaPlaybackRequiresUserGesture: false,
                allowFileAccess: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
                useShouldOverrideUrlLoading: true,
                supportMultipleWindows: false,
                iframeAllow: 'camera; microphone; geolocation',
                iframeAllowFullscreen: true,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onPermissionRequest: (controller, request) async {
                if (request.resources.contains(PermissionResourceType.MICROPHONE) ||
                    request.resources.contains(PermissionResourceType.CAMERA)) {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                }
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.DENY,
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url!;
                final fixed = _repairUri(uri.toString());
                if (fixed.toString() != uri.toString() || !fixed.host.contains('ubiquitous-mandazi-271500.netlify.app')) {
                  await _launchExternal(fixed);
                  return NavigationActionPolicy.CANCEL;
                }
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStart: (controller, url) {
                setState(() => isLoading = true);
              },
              onLoadStop: (controller, url) async {
                setState(() => isLoading = false);
                
                // Inyectar JavaScript para solicitar permisos después de cargar
                if (Platform.isIOS) {
                  await controller.evaluateJavascript(source: '''
                    // Verificar si navigator.mediaDevices está disponible
                    if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                      console.log('getUserMedia disponible');
                    }
                  ''');
                }
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.cyan),
            ),
        ],
      ),
    );
  }
}
