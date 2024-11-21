import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantallaEscaneo.dart';
import 'main.dart';

class AnalysisScreen extends StatelessWidget {
  final Uint8List processedImageBytes; // Imagen procesada en formato Uint8List
  final List<List<int>> palette;

  AnalysisScreen({
    required this.processedImageBytes,
    required this.palette,
  });

  // Calcular distancia Euclidiana entre colores
  double colorDistance(List<int> color1, List<int> color2) {
    return sqrt((color1[0] - color2[0]) * (color1[0] - color2[0]) +
        (color1[1] - color2[1]) * (color1[1] - color2[1]) +
        (color1[2] - color2[2]) * (color1[2] - color2[2]));
  }

  // Comparar colores
  String compareColors(List<int> color, List<int> wallColor) {
    double distance = colorDistance(color, wallColor);
    if (distance > 50) {
      return "Color significativamente diferente al de la pared.";
    } else {
      return "El color es similar al de la pared.";
    }
  }

  // Obtener el color de la pared desde SharedPreferences
  Future<List<int>> _getWallColor() async {
    final prefs = await SharedPreferences.getInstance();
    final wallColorString = prefs.getString('wall_color') ?? '255,255,255';
    return wallColorString.split(',').map(int.parse).toList();
  }

  // Convertir RGB a HEX
  String rgbToHex(List<int> rgb) {
    return '#${rgb[0].toRadixString(16).padLeft(2, '0')}${rgb[1].toRadixString(16).padLeft(2, '0')}${rgb[2].toRadixString(16).padLeft(2, '0')}';
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
        'hex': rgbToHex(color),
      };
    }).toList();

    final newPalette = {
      'palette': colorDetails,
      'date': DateTime.now().toIso8601String(),
    };

    savedPalettes.add(newPalette);
    await prefs.setString('saved_palettes', jsonEncode(savedPalettes));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Análisis guardado exitosamente")),
    );
  }

  Widget _buildPaletteColorDetails(List<int> color, BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Detalles del Color"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    color: Color.fromRGBO(color[0], color[1], color[2], 1),
                  ),
                  SizedBox(height: 8),
                  Text("RGB: (${color[0]}, ${color[1]}, ${color[2]})"),
                  Text("HEX: ${rgbToHex(color)}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cerrar"),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.all(8.0),
        width: 50,
        height: 50,
        color: Color.fromRGBO(color[0], color[1], color[2], 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Análisis de Tonos"),
      ),
      body: SingleChildScrollView(
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
              "Paleta Generada",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: palette.map((color) {
                return _buildPaletteColorDetails(color, context);
              }).toList(),
            ),
            SizedBox(height: 20),
            FutureBuilder<List<int>>(
              future: _getWallColor(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error al obtener el color de la pared'));
                }

                final wallColor = snapshot.data ?? [255, 255, 255];
                final dominantColor = palette.reduce((a, b) {
                  return a[0] > b[0] ? a : b;
                });

                return Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      color: Color.fromRGBO(dominantColor[0], dominantColor[1], dominantColor[2], 1),
                    ),
                    Text("RGB: (${dominantColor[0]}, ${dominantColor[1]}, ${dominantColor[2]})"),
                    Text("HEX: ${rgbToHex(dominantColor)}"),
                    SizedBox(height: 20),
                    Text(compareColors(dominantColor, wallColor)),
                  ],
                );
              },
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
      ),
    );
  }
}