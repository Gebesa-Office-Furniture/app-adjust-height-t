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

  // Ejecutar JavaScript para solicitar permisos de audio cuando la pu00e1gina termine de cargar
  Future<void> _requestAudioPermission() async {
    await Future.delayed(const Duration(
        seconds: 2)); // Esperar a que la pu00e1gina cargue completamente
    controller.runJavaScript('''
      navigator.mediaDevices.getUserMedia({ audio: true })
        .then(function(stream) {
          console.log('Micru00f3fono habilitado');
        })
        .catch(function(err) {
          console.error('Error al acceder al micru00f3fono:', err);
        });
    ''');
  }

  @override
  void initState() {
    super.initState();
    // Inicializar el controlador de WebView con configuración para permitir acceso a medios
    controller = WebViewController()
      // Permitir JavaScript sin restricciones (necesario para acceso a medios)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Fondo transparente
      ..setBackgroundColor(const Color(0x00000000))
      // Configurar User Agent para mejor compatibilidad
      ..setUserAgent(
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36')
      // Añadir canal JavaScript para comunicación
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          print('WebView message: ${message.message}');
        },
      )
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
      ..loadRequest(Uri.parse('https://thunderous-dango-83ccc5.netlify.app/'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Solicitar permisos de audio despuu00e9s de que el widget estu00e9 completamente inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAudioPermission();
    });
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
