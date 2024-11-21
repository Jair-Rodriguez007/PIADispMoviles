import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _loginUser() async {
    try {
      // Endpoint de autenticación
      final authUrl = Uri.parse('http://192.168.0.3:3000/auth/login');

      // Datos de autenticación
      final response = await http.post(
        authUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        // Procesar la respuesta de autenticación
        final data = jsonDecode(response.body);
        final userId = data['userId']; // Cambia este campo según la respuesta de tu servidor

        print('Usuario autenticado: $userId');

        // Construir la URL para obtener datos del usuario
        final userUrl = Uri.parse('http://192.168.0.3:3000/users/$userId');
        final userResponse = await http.get(userUrl);

        if (userResponse.statusCode == 200) {
          // Procesar la respuesta de datos del usuario
          final userData = jsonDecode(userResponse.body);
          print('Usuario encontrado: $userData');

          // Redirigir a la pantalla principal tras iniciar sesión
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Error al obtener los datos del usuario: ${userResponse.statusCode}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar sesión: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la solicitud: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _loginUser,
              child: Text('Iniciar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}