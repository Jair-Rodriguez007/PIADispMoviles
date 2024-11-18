import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pantallaEscaneo.dart';
import 'main.dart';


class AnalysisScreen extends StatelessWidget {
  final String imagePath;
  final List<List<int>> palette;

  AnalysisScreen({required this.imagePath, required this.palette});

  Future<void> _savePalette(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtener paletas guardadas existentes
    final existingPalettesString = prefs.getString('saved_palettes');
    List<dynamic> savedPalettes = existingPalettesString != null
        ? jsonDecode(existingPalettesString)
        : [];

    // Crear nueva paleta con metadata
    final newPalette = {
      'imagePath': imagePath,
      'palette': palette,
      'date': DateTime.now().toIso8601String(),
    };

    // Guardar nueva paleta
    savedPalettes.add(newPalette);
    await prefs.setString('saved_palettes', jsonEncode(savedPalettes));

    // Mostrar notificación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Análisis guardado exitosamente")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Análisis de Tonos"),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.file(
              File(imagePath),
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
                return Container(
                  margin: EdgeInsets.all(8.0),
                  width: 50,
                  height: 50,
                  color: Color.fromRGBO(color[0], color[1], color[2], 1),
                );
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
      ),
    );
  }
}
