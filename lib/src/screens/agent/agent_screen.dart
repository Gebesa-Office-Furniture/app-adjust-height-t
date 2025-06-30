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

  // ───────────────────── WebView ─────────────────────

  Future<void> _initWebView() async {
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

  /// Solicita permisos de dispositivo basados en los recursos que pide el WebView.
Future<bool> _requestPermissions(List<PermissionResourceType> resources) async {
  if (resources.isEmpty) return true;

  // Evita solicitar el mismo permiso varias veces
  final permissionsToRequest = <Permission>{};

  for (final resource in resources) {
    debugPrint("Processing resource: $resource (type: ${resource.runtimeType})");
    
    // Usar toString() en lugar de toNativeValue() para evitar el error con int
    final resourceString = resource.toString();
    
    // Mapea recursos de WebView a permisos del dispositivo
    if (resourceString.contains('AUDIO_CAPTURE') || 
        resourceString.toLowerCase().contains('microphone')) {
      permissionsToRequest.add(Permission.microphone);
    }
    
    if (resourceString.contains('VIDEO_CAPTURE') || 
        resourceString.toLowerCase().contains('camera')) {
      permissionsToRequest.add(Permission.camera);
    }
    
    // También verificar por comparación directa del enum
    try {
      if (resource == PermissionResourceType.MICROPHONE) {
        permissionsToRequest.add(Permission.microphone);
      }
      if (resource == PermissionResourceType.CAMERA) {
        permissionsToRequest.add(Permission.camera);
      }
    } catch (e) {
      debugPrint("Error comparando enum: $e");
    }
  }

  if (permissionsToRequest.isEmpty) {
    debugPrint("No se encontraron permisos reconocidos en: $resources");
    return true;
  }

  debugPrint("Solicitando permisos: $permissionsToRequest");

  try {
    // Solicita todos los permisos necesarios
    final statuses = await permissionsToRequest.toList().request();
    
    // Verifica si todos los permisos fueron otorgados
    final allGranted = statuses.values.every((status) => status.isGranted);
    debugPrint("Resultado de permisos: $statuses");
    
    return allGranted;
  } catch (e) {
    debugPrint("Error al solicitar permisos: $e");
    return false;
  }
}

/// Método auxiliar para Android que recibe List<String>
Future<bool> _requestPermissionsFromStrings(List<String> resources) async {
  if (resources.isEmpty) return true;

  final permissionsToRequest = <Permission>{};

  for (final resource in resources) {
    if (resource.contains('AUDIO_CAPTURE') || 
        resource.toLowerCase().contains('microphone')) {
      permissionsToRequest.add(Permission.microphone);
    }
    if (resource.contains('VIDEO_CAPTURE') || 
        resource.toLowerCase().contains('camera')) {
      permissionsToRequest.add(Permission.camera);
    }
  }

  if (permissionsToRequest.isEmpty) return true;

  try {
    final statuses = await permissionsToRequest.toList().request();
    return statuses.values.every((status) => status.isGranted);
  } catch (e) {
    debugPrint("Error al solicitar permisos en Android: $e");
    return false;
  }
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
                iframeAllow: 'microphone *; camera *',
                iframeAllowFullscreen: true,
                // iOS specific settings for media capture
                allowsAirPlayForMediaPlayback: true,
                allowsPictureInPictureMediaPlayback: true,
                allowsBackForwardNavigationGestures: false,
              ),
              onWebViewCreated: (controller) {
                _controller = controller;
              },
              onPermissionRequest: (controller, request) async {
              debugPrint(">>>> iOS PERMISSION REQUEST: ${request.resources}");
              final granted = await _requestPermissions(request.resources); // SIN .cast<String>()
              return PermissionResponse(
                resources: request.resources,
                action: granted 
                    ? PermissionResponseAction.GRANT 
                    : PermissionResponseAction.DENY,
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
              },
              onReceivedServerTrustAuthRequest: (controller, challenge) async {
                return ServerTrustAuthResponse(
                  action: ServerTrustAuthResponseAction.PROCEED,
                );
              },
              androidOnPermissionRequest: (controller, origin, resources) async {
              debugPrint(">>>> Android PERMISSION REQUEST: $resources");
              final granted = await _requestPermissionsFromStrings(resources);
              return PermissionRequestResponse(
                resources: resources,
                action: granted
                    ? PermissionRequestResponseAction.GRANT
                    : PermissionRequestResponseAction.DENY,
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
