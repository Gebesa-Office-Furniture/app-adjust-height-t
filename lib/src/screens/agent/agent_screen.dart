import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../controllers/settings/theme_controller.dart';
import '../../controllers/settings/language_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/token_manager.dart';

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

    // Generate URL with parameters
    String shUrl = 'https://lucky-medovik-a419a7.netlify.app/';
    String url = '$shUrl?lang=$langParam&theme=$themeParam';

    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onPageStarted: (url) {
          setState(() => isLoading = true);
          _cookieManager.setCookie(WebViewCookie(
              name: 'jwt_token', value: jwtToken!, domain: shUrl));
        }, onPageFinished: (url) {
          setState(() => isLoading = false);
        }),
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
