import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({Key? key}) : super(key: key);

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de WebView
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Actualizar indicador de carga
            if (progress < 100) {
              setState(() {
                isLoading = true;
              });
            } else {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(
          'https://chat.openai.com/')); // URL del chat de OpenAI como ejemplo
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Agregamos Padding con mu00e1rgenes superior e inferior segu00fan el dispositivo
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              // Aumentamos el margen inferior sumando un valor adicional al padding del sistema
              bottom: MediaQuery.of(context).padding.bottom + 80,
            ),
            child: WebViewWidget(controller: controller),
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
