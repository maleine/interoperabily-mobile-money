import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/inscription.dart';
import 'package:interoperabilite/widgets/colors.dart'; // Import de la classe colors
import 'package:intl_phone_field/intl_phone_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Page de Connexion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Connexion(),
        '/inscription': (context) => Inscription(), // Route pour la page d'inscription
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class Connexion extends StatefulWidget {
  const Connexion({super.key});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    final String numero = _phoneController.text.trim();
    final String formattedNumero = '+221$numero';
    final String password = _passwordController.text;
    ApiService apiService = ApiService();

    try {
      var loginResponse = await apiService.login(formattedNumero, password);
      print("Réponse de l'API: $loginResponse");

      if (loginResponse['message'] == 'Connexion réussie') {
        final String userName = loginResponse['name'];
        print("Nom de l'utilisateur: $userName");

        Navigator.pushReplacementNamed(context, '/interoperabilityPage', arguments: userName);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la connexion')),
        );
      }
    } catch (e) {
      print('Erreur lors de la connexion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la connexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30), // Espace entre la barre de statut et le titre
                  _buildHeader(),
                  const SizedBox(height: 30), // Espace entre l'icône et le champ téléphone
                  _buildPhoneField(),
                  const SizedBox(height: 10),
                  _buildPasswordField(),
                  const SizedBox(height: 10),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: _buildStyledButton(),
                  ),
                  const SizedBox(height: 10),
                  _buildSignUpLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => ColorTheme.focusedGradient.createShader(bounds),
          child: const Icon(
            Icons.person,
            size: 80,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro de téléphone',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        IntlPhoneField(
          controller: _phoneController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            hintText: 'Numéro de téléphone',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.phone, color: Colors.grey),
          ),
          initialCountryCode: 'SN',
          onChanged: (phone) {
            print(phone.completeNumber);
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mot de passe',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            hintText: 'Mot de passe',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/MotDePasseOublie');
        },
        child: const Text(
          'Mot de passe oublié ?',
          style: TextStyle(
            color: Colors.blue,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildStyledButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.0),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _login,
        child: Ink(
          decoration: BoxDecoration(
            gradient: ColorTheme.focusedGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(
              minWidth: 88,
              minHeight: 50,
            ),
            child: const Text(
              'Se connecter',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          const TextSpan(
            text: 'Vous n\'avez pas de compte ? ',
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          TextSpan(
            text: 'Inscrivez-vous',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.pushNamed(context, '/inscription');
              },
          ),
        ],
      ),
    );
  }
}
