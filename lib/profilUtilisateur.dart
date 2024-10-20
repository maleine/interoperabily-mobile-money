import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:interoperabilite/widgets/colors.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/ModifierUtilisateur.dart'; // Assurez-vous que ce chemin est correct
import 'package:share_plus/share_plus.dart'; // Importer le package pour le partage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilUtilisateur(), // Page d'accueil
    );
  }
}

class ProfilUtilisateur extends StatefulWidget {
  @override
  _ProfilUtilisateurState createState() => _ProfilUtilisateurState();
}

class _ProfilUtilisateurState extends State<ProfilUtilisateur> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  ApiService apiService = ApiService();

  String userName = '';
  String userNumero = ''; // Ces champs seront remplis par l'API

  @override
  void initState() {
    super.initState();
    // Récupérer les informations de l'utilisateur lors de l'initialisation du widget
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      Map<String, dynamic> userInfo = await apiService.getUserInfo();
      setState(() {
        userName = userInfo['name'];
        userNumero = userInfo['numero'];
      });
    } catch (e) {
      print('Erreur lors de la récupération des informations de l\'utilisateur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération des informations')),
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print('Erreur lors du choix de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du choix de l\'image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(File(_imageFile!.path))
                        : null,
                    child: _imageFile == null
                        ? Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey[800],
                    )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.grey[800],
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            Text(
              userName, // Affiche le nom de l'utilisateur
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              userNumero, // Affiche le numéro de téléphone de l'utilisateur
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30.0),
            _buildOption(context, 'Modifier Profil', Icons.edit),
            _buildOption(context, 'Partager l\'Application', Icons.share),
            _buildOption(
              context,
              'Se Déconnecter',
              Icons.logout,
              action: () async {
                bool? confirm = await _showLogoutConfirmationDialog(context);
                if (confirm == true) {
                  try {
                    await apiService.logout();
                    // Redirige vers la page de connexion après la déconnexion
                    Navigator.of(context).pushReplacementNamed('/connexion');
                  } catch (e) {
                    print('Erreur lors de la déconnexion: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de la déconnexion')),
                    );
                  }
                }
              },
            ),
            _buildOption(
              context,
              'Supprimer Profil',
              Icons.delete,
              action: () async {
                bool? confirm = await _showDeleteConfirmationDialog(context);
                if (confirm == true) {
                  try {
                    await apiService.archiveUser(); // Appel à la fonction d'archivage
                    // Rediriger l'utilisateur vers la page de connexion ou une autre page après l'archivage
                    Navigator.of(context).pushReplacementNamed('/connexion');
                  } catch (e) {
                    print('Erreur lors de l\'archivage de l\'utilisateur: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur lors de l\'archivage du profil')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Déconnexion'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer le Profil'),
          content: Text('Êtes-vous sûr de vouloir supprimer votre profil ? Cette action est irréversible.'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, {Function()? action}) {
    return ListTile(
      title: Text(title),
      leading: _buildGradientIcon(icon, 24.0),
      onTap: () {
        if (title == 'Modifier Profil') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileEditPage(),
            ),
          );
        } else if (title == 'Partager l\'Application') {
          // Utilisation de Share.share pour partager l'application via les réseaux sociaux
          Share.share(
            'Découvrez cette application incroyable ! Téléchargez-la depuis ce lien : https://lien-vers-votre-application.com',
            subject: 'Découvrez cette application !',
          );
        } else if (action != null) {
          action();
        } else {
          print('$title tapped');
        }
      },
    );
  }

  Widget _buildGradientIcon(IconData icon, double size) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [
          ColorTheme.focusedGradient.colors[0],
          ColorTheme.focusedGradient.colors[1],
          ColorTheme.focusedGradient.colors[2],
          ColorTheme.focusedGradient.colors[3],
        ],
      ).createShader(bounds),
      child: Icon(
        icon,
        size: size,
        color: Colors.white,
      ),
    );
  }
}
