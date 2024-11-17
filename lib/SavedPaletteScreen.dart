import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedPaletteScreen extends StatefulWidget {
  @override
  _SavedPaletteScreenState createState() => _SavedPaletteScreenState();
}

class _SavedPaletteScreenState extends State<SavedPaletteScreen> {
  List<List<int>>? _savedPalette;

  @override
  void initState() {
    super.initState();
    _loadSavedPalette();
  }

  Future<void> _loadSavedPalette() async {
    final prefs = await SharedPreferences.getInstance();
    final paletteString = prefs.getString('saved_palette');

    if (paletteString != null) {
      setState(() {
        _savedPalette = List<List<int>>.from(jsonDecode(paletteString).map((color) => List<int>.from(color)));
      });
    } else {
      print("No hay paleta guardada");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paleta Guardada"),
      ),
      body: _savedPalette == null
          ? Center(child: Text("No hay paleta guardada"))
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Paleta Guardada",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _savedPalette!.map((color) {
              return Container(
                margin: EdgeInsets.all(8.0),
                width: 50,
                height: 50,
                color: Color.fromRGBO(color[0], color[1], color[2], 1),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
