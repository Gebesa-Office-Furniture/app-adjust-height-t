import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
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
  WebViewController? _controller;
  bool isLoading = true;

  late final WebViewCookieManager _cookieManager = WebViewCookieManager();

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
    await _cookieManager.setCookie(WebViewCookie(
      name: 'jwt_token',
      value: '$jwt,,,,,$uuid,,,,,$userId,,,,,$tz',
      domain: host,
      path: '/',
    ));

    // ── Config común ──
    const baseParams = PlatformWebViewControllerCreationParams();
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      // ── iOS / macOS ──
      params = WebKitWebViewControllerCreationParams
          .fromPlatformWebViewControllerCreationParams(
        baseParams,
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        limitsNavigationsToAppBoundDomains: true, // 🔑 App-Bound
      );
    } else {
      // ── Android / otras ──
      params = baseParams;
    }

    // ── Crea el controlador concediendo permisos desde el inicio ──
    final ctrl = WebViewController.fromPlatformCreationParams(
      params,
      onPermissionRequest: (request) async {
        if (request.types.contains(WebViewPermissionResourceType.microphone) ||
            request.types.contains(WebViewPermissionResourceType.camera)) {
          await request.grant(); // micrófono / cámara
        } else {
          await request.deny();
        }
      },
    );
    
    // Configurar JavaScript primero
    await ctrl.setJavaScriptMode(JavaScriptMode.unrestricted);
    
    // Configurar el delegado de navegación
    await ctrl.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (request) async {
          final fixed = _repairUri(request.url);
          if (fixed.toString() != request.url || !fixed.host.contains(host)) {
            await _launchExternal(fixed);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageStarted: (_) => setState(() => isLoading = true),
        onPageFinished: (_) async {
          setState(() => isLoading = false);
          
          // Inyectar JavaScript para solicitar permisos después de cargar
          if (Platform.isIOS) {
            await ctrl.runJavaScript('''
              // Verificar si navigator.mediaDevices está disponible
              if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                console.log('getUserMedia disponible');
              }
            ''');
          }
        },
      ),
    );

    // ── Ajustes extra Android ──
    if (ctrl.platform is AndroidWebViewController) {
      final android = ctrl.platform as AndroidWebViewController;
      android
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnShowFileSelector((params) async {
          final picked = await FilePicker.platform.pickFiles(
            allowMultiple: params.mode == FileSelectorMode.open,
            type: FileType.any,
          );
          if (picked == null || picked.files.isEmpty) return [];
          return picked.files
              .where((f) => f.path != null)
              .map((f) => File(f.path!).uri.toString())
              .toList();
        });
    }
    
    // ── Ajustes extra iOS ──
    if (ctrl.platform is WebKitWebViewController) {
      final webkit = ctrl.platform as WebKitWebViewController;
      // Permitir reproducción automática de medios
      await webkit.setAllowsBackForwardNavigationGestures(false);
    }

    setState(() => _controller = ctrl);
    
    // Cargar la URL al final, después de toda la configuración
    await ctrl.loadRequest(url);
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
            child: _controller == null
                ? const SizedBox()
                : WebViewWidget(controller: _controller!),
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
