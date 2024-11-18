import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPaletteScreen extends StatefulWidget {
  @override
  _SavedPaletteScreenState createState() => _SavedPaletteScreenState();
}

class _SavedPaletteScreenState extends State<SavedPaletteScreen> {
  List<Map<String, dynamic>> _savedPalettes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedPalettes();
  }

  Future<void> _loadSavedPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final palettesString = prefs.getString('saved_palettes');

    if (palettesString != null) {
      setState(() {
        _savedPalettes = List<Map<String, dynamic>>.from(
          jsonDecode(palettesString).map((palette) => {
            'imagePath': palette['imagePath'],
            'palette': List<List<int>>.from(
              palette['palette'].map((color) => List<int>.from(color)),
            ),
            'date': palette['date'],
          }),
        );
      });
    }
  }

  Future<void> _deletePalette(int index) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedPalettes.removeAt(index);
    });

    await prefs.setString('saved_palettes', jsonEncode(_savedPalettes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paletas Guardadas"),
      ),
      body: _savedPalettes.isEmpty
          ? Center(child: Text("No hay paletas guardadas"))
          : ListView.builder(
        itemCount: _savedPalettes.length,
        itemBuilder: (context, index) {
          final paletteData = _savedPalettes[index];
          final palette = List<List<int>>.from(paletteData['palette']);
          final date = DateTime.parse(paletteData['date']);
          final imagePath = paletteData['imagePath'];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar la imagen
                if (File(imagePath).existsSync())
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  )
                else
                  Container(
                    height: 200,
                    color: Colors.grey,
                    child: Center(child: Text("Imagen no disponible")),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Fecha: ${date.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: palette.map((color) {
                    return Container(
                      margin: EdgeInsets.all(4.0),
                      width: 40,
                      height: 40,
                      color: Color.fromRGBO(color[0], color[1], color[2], 1),
                    );
                  }).toList(),
                ),
                TextButton(
                  onPressed: () => _deletePalette(index),
                  child: Text("Eliminar"),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
