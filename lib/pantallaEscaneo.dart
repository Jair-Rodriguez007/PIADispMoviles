import 'dart:convert';
import 'dart:typed_data';
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

      // Enviar la imagen al servidor Python para procesarla
      final processedImageBytes = await _sendImageToPythonServer(imagePath);

      // Extraer colores de la imagen procesada
      final colors = await _extractColorsFromBytes(processedImageBytes);

      // Generar paleta de colores a partir de los colores extraídos
      final palette = await _generatePalette(colors);

      setState(() {
        _isAnalyzing = false;
      });

      // Navegar a la pantalla de análisis
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(
            processedImageBytes: processedImageBytes,
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

  Future<Uint8List> _sendImageToPythonServer(String imagePath) async {
    try {
      final url = Uri.parse("http://192.168.0.3:5000/process_image");

      // Crear una solicitud de multipart
      var request = http.MultipartRequest('POST', url);
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      // Enviar la solicitud y obtener la respuesta
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return base64Decode(jsonDecode(responseBody)['processed_image']);
      } else {
        throw Exception("Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error al enviar la imagen al servidor: $e");
    }
  }

  Future<List<List<int>>> _extractColorsFromBytes(Uint8List imageBytes) async {
    final decodedImage = img.decodeImage(imageBytes);

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