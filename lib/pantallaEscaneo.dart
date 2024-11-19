import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'pantallaAnalisis.dart'; // Pantalla de análisis
import 'package:image/image.dart' as img; // Para procesar la imagen
import 'package:shared_preferences/shared_preferences.dart'; // Para manejar configuraciones

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
      final image = await _cameraController!.takePicture();
      final imagePath = image.path;

      final colors = await _extractColorsFromImage(imagePath);

      final palette = await _generatePalette(colors);

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
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al analizar: $e")),
      );
    }
  }

  Future<List<List<int>>> _extractColorsFromImage(String imagePath) async {
    final bytes = File(imagePath).readAsBytesSync();
    final decodedImage = img.decodeImage(bytes);

    if (decodedImage == null) throw Exception("No se pudo procesar la imagen");

    final resizedImage = img.copyResize(decodedImage, width: 200, height: 200);

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

    final sortedColors = colorMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedColors.take(5).map((e) {
      final parts = e.key.split(',').map(int.parse).toList();
      return parts;
    }).toList();
  }

  Future<List<List<int>>> _generatePalette(List<List<int>> colors) async {
    final prefs = await SharedPreferences.getInstance();
    final sensitivity = prefs.getString('sensitivity') ?? 'Grado 1: Muy leve';
    final wallColorString = prefs.getString('wall_color') ?? '255,255,255';
    final wallColor = wallColorString.split(',').map(int.parse).toList();

    final colorCount = {
      'Grado 1: Muy leve': 3,
      'Grado 2: Leve': 5,
      'Grado 3: Moderado': 7,
      'Grado 4: Fuerte': 10,
    }[sensitivity]!;

    final inputColors = colors.take(colorCount).toList();
    inputColors.insert(0, wallColor);

    final url = "http://colormind.io/api/";

    final body = {
      "model": "default",
      "input": inputColors.map((c) => c.isEmpty ? "N" : c).toList(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<List<int>>.from(data["result"].map((color) => List<int>.from(color)));
      } else {
        throw Exception("Error al conectar con Colormind: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
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
