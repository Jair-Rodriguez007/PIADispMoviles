// pantallaAnalisis.dart
import 'package:flutter/material.dart';

class AnalysisScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFbfbeac),
        title: Text('Resultado'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('• Área 1: Tono desigual en la parte superior izquierda'),
            Text('• Área 2: Tono desigual en la parte central derecha'),
            SizedBox(height: 20),
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
