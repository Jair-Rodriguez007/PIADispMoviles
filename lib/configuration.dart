import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> items = [
    'Grado 1: Muy leve',
    'Grado 2: Leve',
    'Grado 3: Moderado',
    'Grado 4: Fuerte'
  ];
  String? selectedValue;
  Color color = Colors.red;
  bool camera_access = false;
  bool notifications_access = false;
  bool files_access = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSensitivity = prefs.getString('selected_sensitivity') ?? items[0];
    final savedColorString = prefs.getString('wall_color') ?? '255,0,0';
    final colorParts = savedColorString.split(',').map(int.parse).toList();

    setState(() {
      selectedValue = savedSensitivity;
      color = Color.fromARGB(255, colorParts[0], colorParts[1], colorParts[2]);
    });
  }

  // Guardar configuración en SharedPreferences
  Future<void> saveSettings(String? sensitivity, Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_sensitivity', sensitivity ?? '');
    await prefs.setString('wall_color', '${color.red},${color.green},${color.blue}');
  }

  // Guardar sensibilidad y notificar al usuario
  void onSaveSettings(BuildContext context) async {
    await saveSettings(selectedValue, color);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configuración guardada exitosamente")),
    );
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      camera_access = status.isGranted;
    });
  }

  Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      notifications_access = status.isGranted;
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.storage.request();
    setState(() {
      files_access = status.isGranted;
      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    });
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
      title: const Text("Selecciona un color"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildColorPicker(),
          TextButton(
            child: const Text(
              "Guardar Ajustes",
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              onSaveSettings(context);
            },
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
        centerTitle: true,
        elevation: 2.0,
        backgroundColor: Colors.blueGrey[800],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Text("Sensibilidad y Colores",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text("Sensibilidad de color:",
                      style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Elige el grado',
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      items: items
                          .map((String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(fontSize: 17),
                        ),
                      ))
                          .toList(),
                      value: selectedValue,
                      onChanged: (String? value) {
                        setState(() {
                          selectedValue = value;
                        });
                        onSaveSettings(context);
                      },
                      buttonStyleData: const ButtonStyleData(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        height: 50,
                        width: 170,
                      ),
                      menuItemStyleData: const MenuItemStyleData(height: 50),
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
                    style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 14)),
                    onPressed: () => pickColor(context),
                    child: const Text('Elige el color de la pared',
                        style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text("Permisos",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),
              Column(children: [
                Row(children: [
                  const Icon(Icons.camera_alt_sharp, color: Colors.grey, size: 40.0),
                  const Text('   Cámara', style: TextStyle(fontSize: 20)),
                  const Spacer(),
                  Checkbox(
                    value: camera_access,
                    onChanged: (value) => requestCameraPermission(),
                  ),
                ]),
                Row(
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.yellow, size: 40.0),
                    const Text('   Notificaciones', style: TextStyle(fontSize: 20)),
                    const Spacer(),
                    Checkbox(
                      value: notifications_access,
                      onChanged: (value) => requestNotificationPermission(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.file_open_outlined,
                        color: Colors.black, size: 40.0),
                    const Text('   Archivos', style: TextStyle(fontSize: 20)),
                    const Spacer(),
                    Checkbox(
                      value: files_access,
                      onChanged: (value) => _requestPermissions(),
                    ),
                  ],
                ),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
