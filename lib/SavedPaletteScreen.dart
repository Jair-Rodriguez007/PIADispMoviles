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
    _loadSavedPalettes();  // Cargar paletas al iniciar la pantalla
  }

  // Cargar las paletas guardadas desde SharedPreferences
  Future<void> _loadSavedPalettes() async {
    final prefs = await SharedPreferences.getInstance();
    final palettesString = prefs.getString('saved_palettes');

    if (palettesString != null) {
      setState(() {
        _savedPalettes = List<Map<String, dynamic>>.from(
          jsonDecode(palettesString).map((palette) {
            return {
              'imagePath': palette['imagePath'],
              'palette': List<Map<String, dynamic>>.from(palette['palette'].map((color) => Map<String, dynamic>.from(color))),
              'date': palette['date'],
            };
          }),
        );
      });
    }
  }

  // Eliminar una paleta guardada
  Future<void> _deletePalette(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final confirmed = await _showDeleteConfirmationDialog();

    if (confirmed) {
      setState(() {
        _savedPalettes.removeAt(index);
      });
      await prefs.setString('saved_palettes', jsonEncode(_savedPalettes));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paleta eliminada")));
    }
  }

  // Mostrar un diálogo de confirmación para eliminar
  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar Eliminación"),
        content: Text("¿Estás seguro de que quieres eliminar esta paleta?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text("Eliminar"),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Paletas Guardadas")),
      body: _savedPalettes.isEmpty
          ? Center(child: Text("No hay paletas guardadas"))
          : ListView.builder(
        itemCount: _savedPalettes.length,
        itemBuilder: (context, index) {
          final paletteData = _savedPalettes[index];
          final palette = paletteData['palette'];
          final date = DateTime.parse(paletteData['date']);
          final imagePath = paletteData['imagePath'];

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar la imagen completa, con la misma altura que en la pantalla de análisis
                if (File(imagePath).existsSync())
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    width: 200,
                    height: 300,
                  )
                else
                  Container(
                    height: 100,
                    color: Colors.grey,
                    child: Center(child: Text("Imagen no disponible")),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Fecha: ${date.toLocal().toString().split(' ')[0]}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                // Mostrar los detalles de cada color en la paleta
                Column(
                  children: palette.map<Widget>((color) {
                    return ListTile(
                      contentPadding: EdgeInsets.all(8.0),
                      leading: Container(
                        width: 40,
                        height: 40,
                        color: Color.fromRGBO(color['rgb'][0], color['rgb'][1], color['rgb'][2], 1),
                      ),
                      title: Text("RGB: (${color['rgb'][0]}, ${color['rgb'][1]}, ${color['rgb'][2]})"),
                      subtitle: Text("HEX: ${color['hex']}"),
                    );
                  }).toList(),
                ),
                // Botón de eliminar
                TextButton(
                  onPressed: () => _deletePalette(index),
                  child: Text("Eliminar", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
