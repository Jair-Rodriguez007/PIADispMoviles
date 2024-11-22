import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantallaEscaneo.dart';
import 'main.dart';

class AnalysisScreen extends StatelessWidget {
  final Uint8List processedImageBytes; // Imagen procesada
  final List<List<int>> palette; // Paleta de colores generada

  AnalysisScreen({
    required this.processedImageBytes,
    required this.palette,
  });

  // Calcular distancia entre colores
  double colorDistance(List<int> color1, List<int> color2) {
    return sqrt((color1[0] - color2[0]) * (color1[0] - color2[0]) +
        (color1[1] - color2[1]) * (color1[1] - color2[1]) +
        (color1[2] - color2[2]) * (color1[2] - color2[2]));
  }

  // Obtener el color elegido de la configuración
  Future<List<int>> _getSelectedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColorString = prefs.getString('wall_color') ?? '255,255,255';
    return savedColorString.split(',').map(int.parse).toList();
  }

  // Comparar colores y generar texto descriptivo
  String compareWithSelectedColor(List<int> paletteColor, List<int> selectedColor) {
    double distance = colorDistance(paletteColor, selectedColor);

    if (distance > 50) {
      return "Diferente al color configurado.";
    } else {
      return "Similar al color configurado.";
    }
  }

  // Mostrar detalles de cada color de la paleta
  Widget _buildPaletteDetails(List<int> color, List<int> selectedColor) {
    final comparisonResult = compareWithSelectedColor(color, selectedColor);

    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          color: Color.fromRGBO(color[0], color[1], color[2], 1),
        ),
        SizedBox(height: 8),
        Text(
          "RGB: (${color[0]}, ${color[1]}, ${color[2]})",
          style: TextStyle(fontSize: 12),
        ),
        Text(
          comparisonResult,
          style: TextStyle(
            fontSize: 12,
            color: comparisonResult.contains("Diferente") ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  // Guardar la paleta de colores
  Future<void> _savePalette(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final existingPalettesString = prefs.getString('saved_palettes');
    List<dynamic> savedPalettes = existingPalettesString != null
        ? jsonDecode(existingPalettesString)
        : [];

    List<Map<String, dynamic>> colorDetails = palette.map((color) {
      return {
        'rgb': color,
        'hex': '#${color[0].toRadixString(16).padLeft(2, '0')}${color[1].toRadixString(16).padLeft(2, '0')}${color[2].toRadixString(16).padLeft(2, '0')}',
      };
    }).toList();

    final newPalette = {
      'palette': colorDetails,
      'date': DateTime.now().toIso8601String(),
      //'imagePath': imagePath,
      // Guarda la ruta de la imagen
    };

    savedPalettes.add(newPalette);
    await prefs.setString('saved_palettes', jsonEncode(savedPalettes));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Análisis guardado exitosamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Análisis de Tonos"),
      ),
      body: FutureBuilder<List<int>>(
        future: _getSelectedColor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error al cargar el color configurado"));
          }

          final selectedColor = snapshot.data ?? [255, 255, 255];

          return SingleChildScrollView(
            child: Column(
              children: [
                // Mostrar la imagen procesada
                Image.memory(
                  processedImageBytes,
                  fit: BoxFit.contain,
                  height: 300,
                ),
                SizedBox(height: 16),
                Text(
                  "Comparación de Colores",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: palette.map((color) {
                    return _buildPaletteDetails(color, selectedColor);
                  }).toList(),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _savePalette(context),
                  child: Text('Guardar Análisis'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ScanScreen()),
                    );
                  },
                  child: Text('Hacer otro Escaneo'),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    );
                  },
                  child: Text('Volver al Menú Principal'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}