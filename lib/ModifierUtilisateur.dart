import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/profilUtilisateur.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:interoperabilite/widgets/colors.dart'; // Assurez-vous d'importer ColorTheme

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
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      print('Token utilisé avant getUserInfo: ${apiService.token}');
      Map<String, dynamic> userInfo = await apiService.getUserInfo();
      setState(() {
        _nameController.text = userInfo['name'];
        _phoneController.text = userInfo['numero'].replaceFirst('+221', '');
        _passwordController.text = userInfo['password'];
        _confirmPasswordController.text = userInfo['confirmpassword'];
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
    _confirmPasswordController.dispose();
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
      await apiService.updateUser(
        name: _nameController.text,
        numero: '+221${_phoneController.text}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil mis à jour avec succès')),
      );

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
        title: Text('Modifier Profil', style: TextStyle(fontSize: 12)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Bordure arrondie de 20
                  borderSide: BorderSide(),
                ),
              ),
              style: TextStyle(fontSize: 12),
              maxLines: 1, // Limiter à une seule ligne pour réduire la hauteur
            ),
            SizedBox(height: 12), // Hauteur réduite entre les champs
            IntlPhoneField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone',
                labelStyle: TextStyle(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20), // Bordure arrondie de 20
                  borderSide: BorderSide(),
                ),
              ),
              initialCountryCode: 'SN',
              style: TextStyle(fontSize: 12),
              onChanged: (phone) {
                print(phone.completeNumber);
              },
            ),
            SizedBox(height: 12), // Hauteur réduite entre les champs
            ElevatedButton(
              onPressed: _updateUserInfo,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: ColorTheme.focusedGradient.colors.first, // Dégradé appliqué
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: ColorTheme.focusedGradient.colors,
                ).createShader(bounds),
                child: Text('Sauvegarder', style: TextStyle(fontSize: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
