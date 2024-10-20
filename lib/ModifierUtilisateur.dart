import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart'; // Assurez-vous d'importer correctement votre ApiService
import 'package:interoperabilite/profilUtilisateur.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // Importer IntlPhoneField

class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  ApiService apiService = ApiService(); // Instance de ApiService
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController(); // Ajout du champ de confirmation

  @override
  void initState() {
    super.initState();
    // Appel à getUserInfo pour remplir les champs
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      // Afficher le token avant d'appeler getUserInfo
      print('Token utilisé avant getUserInfo: ${apiService.token}'); // Utiliser le getter

      // Appel à la méthode getUserInfo via ApiService
      Map<String, dynamic> userInfo = await apiService.getUserInfo();
      setState(() {
        _nameController.text = userInfo['name'];
        _phoneController.text = userInfo['numero'].replaceFirst('+221', '');
        _passwordController.text=userInfo['password'];
        _confirmPasswordController.text=userInfo['confirmpassword'];
        // Correction ici pour le téléphone
      });
    } catch (e) {
      print('Erreur lors de la récupération des informations utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des informations')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose(); // Dispose du champ de confirmation
    super.dispose();
  }

  Future<void> _updateUserInfo() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    try {
      // Appel à la méthode updateUser via ApiService
      await apiService.updateUser(
        name: _nameController.text,
        numero: '+221${_phoneController.text}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès')),
      );

      // Redirection vers la page ProfilUtilisateur
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfilUtilisateur()),
      );
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du profil')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            SizedBox(height: 24),
            IntlPhoneField(
              controller: _phoneController, // Utiliser IntlPhoneField pour le numéro de téléphone
              decoration: InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'SN', // Remplacez par le code pays par défaut si nécessaire
              onChanged: (phone) {
                print(phone.completeNumber); // Vous pouvez utiliser le numéro complet
              },
            ),

            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _updateUserInfo(); // Mise à jour des infos utilisateur
              },
              child: Text('Sauvegarder'),
            ),
          ],
        ),
      ),
    );
  }
}
