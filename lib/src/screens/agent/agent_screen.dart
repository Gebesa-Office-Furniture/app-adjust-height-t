import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:permission_handler/permission_handler.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});
  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  WebViewController? _controller; // ① ahora es nullable
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    await [Permission.microphone].request();

    final ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // …todas tus demás llamadas…
      ..loadRequest(Uri.parse('https://thunderous-dango-83ccc5.netlify.app/'));

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

    setState(() => _controller = ctrl); // ② lo asignamos de golpe
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
            child: _controller == null // ③
                ? const SizedBox() // mientras se crea
                : WebViewWidget(controller: _controller!), // cuando ya existe
          ),
          //if (isLoading)
          //const Center(child: CircularProgressIndicator(color: Colors.cyan)),
        ],
      ),
    );
  }
}
