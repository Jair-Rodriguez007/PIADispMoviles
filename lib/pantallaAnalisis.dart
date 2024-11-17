import 'dart:io';
import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  final String imagePath;
  final List<List<int>> palette;

  AnalysisScreen({required this.imagePath, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Análisis de Tonos"),
      ),
      body: SingleChildScrollView( // Permitir desplazamiento
        child: Column(
          children: [
            Image.file(File(imagePath),
            fit: BoxFit.contain, // Asegura que la imagen se ajuste
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
              onPressed: () {},
              child: Text('Guardar Análisis'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text('Compartir Análisis'),
            ),
          ],
        ),
      ),
    );
  }
}
