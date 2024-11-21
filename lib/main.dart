import 'package:flutter/material.dart';
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
      title: 'Tonos de Pared',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
          bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explorar Tonos de Pared'),
        centerTitle: true,
        elevation: 2.0,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Elige una opción para empezar:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                children: [
                  _buildOptionCard(
                    context,
                    title: 'Escanear image',
                    icon: Icons.image_search,
                    color: Colors.orange,
                    onTap: () {

                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => ScanScreen()),
                       );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Paletas guardadas',
                    icon: Icons.save,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SavedPaletteScreen()),
                      );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Ajustes',
                    icon: Icons.palette,
                    color: Colors.blueGrey,
                    onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) =>  MyHomePage(title: 'Ajustes')),
                       );
                    },
                  ),
                  _buildOptionCard(
                    context,
                    title: 'Ayuda',
                    icon: Icons.help_outline,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Tutorialpage(title: 'Tutorial')),
                      );
                    },
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context,
      {required String title,
        required IconData icon,
        required Color color,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 4.0,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: color.withOpacity(0.1),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 48.0, color: color),
                SizedBox(height: 12.0),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
