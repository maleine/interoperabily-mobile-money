import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/inscription.dart';
import 'package:interoperabilite/widgets/colors.dart'; // Import de la classe colors
import 'package:intl_phone_field/intl_phone_field.dart';



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
          children: [
            // Espace entre la barre des tâches et le triangle en haut
            SizedBox(height: MediaQuery.of(context).padding.top), // Espace ajouté

            // Triangle en haut de la page
            Container(
              height: 160,
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

            // Titre Connexion
            Text(
              'Connexion',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 10), // Espace après le titre

            // Formulaire de connexion
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(

                child: Column(
                  children: [
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                      initialCountryCode: 'SN',
                      onChanged: (phone) {
                        print(phone.completeNumber);
                      },
                    ),
                    SizedBox(height: 16), // Espace entre les champs
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20), // Bordure de 20 pixels
                          borderSide: BorderSide(color: Colors.black), // Couleur de la bordure
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      ),
                    ),
                    SizedBox(height: 16), // Espace entre les champs

                    // Lien mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/MotDePasseOublie');
                        },
                        child: Text(
                          'Mot de passe oublié ?',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Bouton de connexion avec dégradé
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
                        onPressed: _login, // Appel de la méthode de connexion
                        child: Text('Se connecter',
                            style: TextStyle(color: Colors.white)), // Texte en blanc
                      ),
                    ),

                    SizedBox(height: 20), // Espacement avant le lien d'inscription
                    _buildSignUpLink(), // Passer le context ici
                  ],
                ),
              ),
            ),

            // Triangle en bas de la page (inversé)
            Container(
              height: 145,
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



  Widget _buildHeader() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => ColorTheme.focusedGradient.createShader(bounds),
          child: const Icon(
            Icons.person,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 15,
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        IntlPhoneField(
          controller: _phoneController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Diminuer la hauteur
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            hintText: 'Numéro de téléphone',
            hintStyle: const TextStyle(color: Colors.grey,fontSize: 12),
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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16), // Diminuer la hauteur
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            hintText: 'Mot de passe',
            hintStyle: const TextStyle(color: Colors.grey,fontSize: 12),
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
