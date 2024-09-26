import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajustes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Ajustes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> items = ['Grado 1: Muy leve', 'Grado 2: Leve', 'Grado 3: Moderado', 'Grado 4: Fuerte'];
  String? selectedValue;
  Color color = Colors.red;
  bool camera_access = false;
  bool notifications_access = false;
  bool files_access = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.black,
            size: 30.0,
          ),
          onPressed: () {
            Navigator.pop(context);  // Esto regresa a la pantalla anterior (main)
          },
        ),
        title: Text('Ajustes'),
        backgroundColor: Color(0xFF80DEEA),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text("Sensibilidad y Colores", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text("Sensibilidad de color:", style: TextStyle(fontSize: 20)),
                  Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Elige el grado',
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme
                              .of(context)
                              .hintColor,
                        ),
                      ),
                      items: items
                          .map((String item) =>
                          DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ))
                          .toList(),
                      value: selectedValue,
                      onChanged: (String? value) {
                        setState(() {
                          selectedValue = value;
                        });
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        width: 170,
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 50,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontSize: 14)),
                    onPressed: () => pickColor(context),
                    child: const Text('Elige el color de la pared', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text("Permisos", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Column(
                children: [
                  Row(
                      children: [
                        Icon(
                          Icons.camera_alt_sharp,
                          color: Colors.grey,
                          size: 40.0,
                        ),
                        Text('   Cámara', style: TextStyle(fontSize: 20)),
                        Spacer(),
                        Checkbox(
                          value: camera_access,
                          onChanged: (value) {
                            setState(() {
                              camera_access = value!;
                            });
                          },
                        ),
                      ]
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.notifications,
                        color: Colors.yellow,
                        size: 40.0,
                      ),
                      Text('   Notificaciones', style: TextStyle(fontSize: 20)),
                      Spacer(),
                      Checkbox(
                        value: notifications_access,
                        onChanged: (value) {
                          setState(() {
                            notifications_access = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.file_open_outlined,
                        color: Colors.black,
                        size: 40.0,
                      ),
                      Text('   Archivos', style: TextStyle(fontSize: 20)),
                      Spacer(),
                      Checkbox(
                        value: files_access,
                        onChanged: (value) {
                          setState(() {
                            files_access = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ]
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildColorPicker() => ColorPicker(
    pickerColor: color,
    enableAlpha: false,
    showLabel: false,
    onColorChanged: (color) => setState(() => this.color = color),
  );

  void pickColor(BuildContext context) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Pick your color"),
      content: Column(
        children: [
          buildColorPicker(),
          TextButton(
              child: const Text(
                "Seleccionar",
                style: TextStyle(fontSize: 20),
              ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    ),
  );
}
