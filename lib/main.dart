import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador de Tonos de Pared',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intercolor'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Text(
              'Bienvenido a "Intercolor"',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/logo.png',
              height: 150,
            ),
            SizedBox(height: 20),

            SizedBox(height: 20),
            Text(
              'Logra un acabado perfecto en tus paredes con nuestro comparador de tonos',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanScreen()),
                );
              },
              child: Text('Iniciar Escaneo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Configuración'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Tutorial'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Resumen del Análisis'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Áreas que necesitan más pintura:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),

            Text(
              'Área 1: Necesita pintura\nÁrea 2: Uniformidad adecuada',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              'Recomendaciones:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              '1. Aplique una capa adicional en el Área 1.\n2. Verifique la mezcla de pintura.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Guardar Análisis'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {

              },
              child: Text('Compartir Análisis'),
            ),
          ],
        ),
      ),
    );
  }
}


class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();  // Obtén las cámaras disponibles
    _cameraController = CameraController(
      cameras![0],  // Usa la primera cámara disponible (normalmente la trasera)
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();  // Limpia el controlador cuando la pantalla se destruye
    super.dispose();
  }

  void _captureAndAnalyze() {
    setState(() {
      _isAnalyzing = true;
    });

    // Simular el análisis del color con un retraso
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isAnalyzing = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AnalysisScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Escaneo'),
      ),
      body: Column(
        children: [
          // Vista de la cámara
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)  // Mostrar la vista previa de la cámara
                : Center(child: CircularProgressIndicator()),  // Mostrar un cargador mientras se inicializa
          ),
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),  // Barra de progreso
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _captureAndAnalyze,  // Deshabilitar botón mientras se analiza
              child: Text(_isAnalyzing ? 'Analizando...' : 'Capturar y Analizar'),
            ),
          ),
        ],
      ),
    );
  }
}