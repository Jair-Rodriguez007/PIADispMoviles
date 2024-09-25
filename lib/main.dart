import 'package:flutter/material.dart';

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
            // Aquí mostramos el logo
            Image.asset(
              'assets/logo.png',
              height: 150, // Ajusta el tamaño del logo
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenido a la app de comparación de tonos de pared.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnalysisScreen()),
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