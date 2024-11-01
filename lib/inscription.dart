import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:interoperabilite/OTPScreen.dart';
import 'Api/ApiService.dart';
import 'package:interoperabilite/widgets/colors.dart'; // Importation des couleurs
import 'package:intl_phone_field/intl_phone_field.dart'; // Importation du widget IntlPhoneField

class Inscription extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<Inscription> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String numero = '';
  String password = '';
  String confirmPassword = '';

  ApiService apiService = ApiService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Les mots de passe ne correspondent pas')),
        );
        return;
      }

      try {
        // Étape 1 : Envoi de l'OTP
        var otpResponse = await apiService.register(name, numero, password);
        if (otpResponse['message'] == 'OTP envoyé avec succès') {
          // Naviguer vers la page OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpScreen(numero: numero, name: name, password: password),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors de l\'envoi de l\'OTP')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'inscription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Espace entre la barre des tâches et le triangle en haut
            SizedBox(height: MediaQuery.of(context).padding.top), // Espace ajouté

            // Triangle en haut de la page
            Container(
              height: 125,
              child: CustomPaint(
                painter: DiagonalPainter(), // Appel du custom painter
                child: Container(),
              ),
            ),

            // Icône de la personne
            Icon(
              Icons.person,
              size: 50,
              color: Colors.black,
            ),

            SizedBox(height: 5), // Réduit l'espace après l'icône

            // Titre Inscription
            Text(
              'Inscription',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10), // Espace après le titre

            // Formulaire d'inscription
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                      onChanged: (value) => name = value,
                      validator: (value) =>
                      value!.isEmpty ? 'Veuillez entrer votre nom' : null,
                    ),
                    SizedBox(height: 16), // Espace entre les champs
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                      initialCountryCode: 'SN',
                      onChanged: (phone) {
                        numero = phone.completeNumber;
                      },
                      validator: (value) {
                        if (value == null || value.number.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null; // Aucune erreur
                      },
                    ),
                    SizedBox(height: 8), // Espace entre les champs
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                      obscureText: true,
                      onChanged: (value) => password = value,
                      validator: (value) => value!.length < 6
                          ? 'Le mot de passe doit contenir au moins 6 caractères'
                          : null,
                    ),
                    SizedBox(height: 16), // Espace entre les champs
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmez le mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                      obscureText: true,
                      onChanged: (value) => confirmPassword = value,
                      validator: (value) => value!.isEmpty
                          ? 'Veuillez confirmer votre mot de passe'
                          : null,
                    ),
                    SizedBox(height: 10),

                    // Bouton d'inscription avec dégradé
                    Container(
                      width: double.infinity, // Le bouton prend toute la largeur
                      decoration: BoxDecoration(
                        gradient: ColorTheme.focusedGradient,
                        borderRadius: BorderRadius.circular(20), // Bordure arrondie
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent, // Rendre le bouton transparent pour voir le dégradé
                          shadowColor: Colors.transparent, // Enlever l'ombre
                        ),
                        onPressed: _register,
                        child: Text('S\'inscrire',
                            style: TextStyle(color: Colors.white)), // Texte en blanc
                      ),
                    ),

                    SizedBox(height: 20), // Espacement avant le lien de connexion
                    _buildSignUpLink(context), // Passer le context ici
                  ],
                ),
              ),
            ),

            // Triangle en bas de la page (inversé)
            Container(
              height: 125,
              child: CustomPaint(
                painter: InvertedDiagonalPainter(), // Appel du custom painter inversé
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fonction corrigée avec le context
Widget _buildSignUpLink(BuildContext context) {
  return RichText(
    textAlign: TextAlign.center,
    text: TextSpan(
      children: [
        const TextSpan(
          text: 'Vous avez déjà un compte ? ',
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        TextSpan(
          text: 'Connectez-vous',
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 16,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Navigator.pushNamed(context, '/connexion');
            },
        ),
      ],
    ),
  );
}

class DiagonalPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;

    // Dégradé pour le triangle (haut) utilisant ColorTheme.focusedGradient
    paint.shader = ColorTheme.focusedGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    path.lineTo(0, 0); // Point d'origine (haut gauche)
    path.lineTo(size.width, 0); // Haut droit
    path.lineTo(size.width, size.height); // Bas droit
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// Classe pour le triangle inversé
class InvertedDiagonalPainter extends CustomPainter {
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..style = PaintingStyle.fill;

    // Dégradé pour le triangle (bas) utilisant ColorTheme.focusedGradient
    paint.shader = ColorTheme.focusedGradient
        .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    path.lineTo(size.width, size.height); // Bas droit
    path.lineTo(0, size.height); // Bas gauche
    path.lineTo(0, size.height - size.height); // Point d'origine (haut gauche)
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
