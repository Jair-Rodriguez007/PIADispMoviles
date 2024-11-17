import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'pantallaAnalisis.dart'; // Importa la pantalla de análisis
import 'package:image/image.dart' as img; // Para procesar la imagen
import 'package:shared_preferences/shared_preferences.dart'; // Importa shared_preferences

class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool _isAnalyzing = false;
  List<List<int>>? _palette;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(
      cameras![0],
      ResolutionPreset.high,
    );
    await _cameraController?.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureAndAnalyze() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Captura la imagen
      final image = await _cameraController!.takePicture();
      final imagePath = image.path;
      print("Imagen capturada: $imagePath");

      // Extrae colores predominantes
      final colors = await _extractColorsFromImage(imagePath);
      print("Colores extraídos: $colors");

      // Genera la paleta usando Colormind
      final palette = await _generatePalette(colors);
      print("Paleta generada: $palette");

      // Navegar a la pantalla de análisis
      setState(() {
        _isAnalyzing = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(
            imagePath: imagePath,
            palette: palette,
          ),
        ),
      );
      print("Navegando a AnalysisScreen");
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      print("Error en _captureAndAnalyze: $e");
    }
  }


  Future<List<List<int>>> _extractColorsFromImage(String imagePath) async {
    // Leer la imagen y convertirla a un formato manejable
    final bytes = File(imagePath).readAsBytesSync();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) throw Exception("No se pudo procesar la imagen");

    // Reducir resolución para extraer colores más rápido
    final resizedImage = img.copyResize(decodedImage, width: 100, height: 100);

    // Crear un mapa de colores
    final Map<String, int> colorMap = {};

    for (var y = 0; y < resizedImage.height; y++) {
      for (var x = 0; x < resizedImage.width; x++) {
        final pixel = resizedImage.getPixel(x, y);
        final r = img.getRed(pixel);
        final g = img.getGreen(pixel);
        final b = img.getBlue(pixel);
        final colorKey = "$r,$g,$b";
        colorMap[colorKey] = (colorMap[colorKey] ?? 0) + 1;
      }
    }

    // Ordenar colores por frecuencia
    final sortedColors = colorMap.keys.toList()
      ..sort((a, b) => colorMap[b]!.compareTo(colorMap[a]!));

    // Extraer los 5 colores más frecuentes
    return sortedColors.take(5).map((key) {
      final parts = key.split(',').map(int.parse).toList();
      return parts; // Devuelve [r, g, b]
    }).toList();
  }

  Future<List<List<int>>> _generatePalette(List<List<int>> colors) async {
    final url = "http://colormind.io/api/";
    final body = {
      "model": "default",
      "input": colors.map((c) => c.isEmpty ? "N" : c).toList(),
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final palette = List<List<int>>.from(data["result"].map((color) => List<int>.from(color)));

      // Guardar la paleta generada
      await _savePalette(palette);

      return palette;
    } else {
      throw Exception("Error al conectar con Colormind: ${response.statusCode}");
    }
  }

  /// Guardar la paleta en SharedPreferences
  Future<void> _savePalette(List<List<int>> palette) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final paletteString = jsonEncode(palette); // Convierte la paleta a JSON
      await prefs.setString('saved_palette', paletteString);
      print("Paleta guardada: $palette");
    } catch (e) {
      print("Error al guardar la paleta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pantalla de Escaneo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cameraController != null && _cameraController!.value.isInitialized
                ? CameraPreview(_cameraController!)
                : Center(child: CircularProgressIndicator()),
          ),
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isAnalyzing ? null : _captureAndAnalyze,
              child: Text(_isAnalyzing ? 'Analizando...' : 'Capturar y Analizar'),
            ),
          ),
        ],
      ),
    );
  }
}
