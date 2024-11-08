// tutorialScreen.dart
import 'package:flutter/material.dart';
import 'pantallaEscaneo.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutorial',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Tutorialpage (title: 'Tutorial'),
    );
  }
}

class Tutorialpage extends StatefulWidget {
  const Tutorialpage({super.key, required this.title});
  final String title;

  @override
  State<Tutorialpage> createState() => _TutorialScreen();
}

class _TutorialScreen extends State<Tutorialpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cómo usar el Escáner'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tutorial de Escaneo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildStepCard(
                    context,
                    'Paso 1: Preparar la Cámara',
                    'Permite a la aplicación acceder a la cámara de tu dispositivo. Esto es necesario para que la app pueda capturar la imagen de la pared que deseas analizar.',
                  ),
                  _buildStepCard(
                    context,
                    'Paso 2: Iniciar el Escaneo',
                    'Presiona el botón "Capturar y Analizar" para capturar una imagen de la pared. La cámara capturará una imagen que se usará para comparar tonos.',
                  ),
                  _buildStepCard(
                    context,
                    'Paso 3: Análisis de la Imagen',
                    'Espera mientras la aplicación analiza la imagen. Verás un indicador de progreso mientras se realiza el análisis de los tonos en diferentes áreas.',
                  ),
                  _buildStepCard(
                    context,
                    'Paso 4: Resultados del Análisis',
                    'Después del análisis, se mostrarán los resultados indicando las áreas con desigualdades de tono y recomendaciones para obtener un acabado uniforme.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ScanScreen()),
                  );
                },
                child: Text('Iniciar Escaneo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, String title, String description) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
