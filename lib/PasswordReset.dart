import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart'; // Importer votre ApiService
import 'package:interoperabilite/widgets/colors.dart'; // Importer votre page de couleurs

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final ApiService apiService = ApiService(); // Créer une instance d'ApiService
  late String phoneNumber;
  bool _isLoading = false; // Ajout d'un état pour indiquer le chargement

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    phoneNumber = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _resetPassword() async {
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (password.isNotEmpty && confirmPassword.isNotEmpty) {
      if (password == confirmPassword) {
        setState(() {
          _isLoading = true; // Afficher l'indicateur de chargement
        });

        try {
          await apiService.resetPassword(phoneNumber, password, confirmPassword);

          if (!mounted) return;

          // Afficher un message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Mot de passe réinitialisé avec succès!')),
          );

          // Redirection vers une autre page après la réussite
          Navigator.pushNamed(context,'/connexion'); // Rediriger vers la page de connexion
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Échec de la réinitialisation du mot de passe. Veuillez réessayer.')),
          );
        } finally {
          setState(() {
            _isLoading = false; // Cacher l'indicateur de chargement
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Les mots de passe ne correspondent pas.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Réinitialiser mot de passe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20), // Espace entre l'AppBar et le contenu
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nouveau mot de passe',
                prefixIcon: Icon(Icons.lock), // Icône de clé
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white, // Couleur de fond des champs
              ),
            ),
            SizedBox(height: 16), // Espace entre les champs
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirmer mot de passe',
                prefixIcon: Icon(Icons.lock), // Icône de clé
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white, // Couleur de fond des champs
              ),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator() // Afficher un indicateur de chargement pendant le traitement
                : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent, // Pour utiliser le dégradé
                shadowColor: Colors.transparent, // Supprime l'ombre
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: ColorTheme.focusedGradient, // Utiliser le dégradé de couleur
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text('Réinitialiser mot de passe', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
