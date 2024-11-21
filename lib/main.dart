//main.dart
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'pantallaEscaneo.dart';
import 'configuration.dart';
import 'tutorial.dart';
import 'SavedPaletteScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Comparador de Tonos de Pared',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Ruta inicial (pantalla de login)
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => WelcomeScreen(),
        '/scan': (context) => ScanScreen(),
        '/settings': (context) => MyHomePage(title: 'Ajustes'),
        '/tutorial': (context) => Tutorialpage(title: 'Tutorial'),
        '/savedPalette': (context) => SavedPaletteScreen(),
      },
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intercolor'),
        backgroundColor: Color(0xFFbfbeac),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bienvenido a "Intercolor"',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Image.asset(
              'assets/logo.png',
              height: 250,
            ),
            SizedBox(height: 20),
            Text(
              'Logra un acabado perfecto en tus paredes con nuestro comparador de tonos',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/scan');
              },
              child: Text('Iniciar Escaneo'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Text('Configuración'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tutorial');
              },
              child: Text('Tutorial'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/savedPalette');
              },
              child: Text("Ver Paleta Guardada"),
            ),
          ],
        ),
      ),
    );
  }
}

