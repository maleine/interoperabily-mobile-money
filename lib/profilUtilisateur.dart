import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:interoperabilite/widgets/colors.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/ModifierUtilisateur.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      home: ProfilUtilisateur(),
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
  String userNumero = '';

  @override
  void initState() {
    super.initState();
    loadUserInfo();
  }

  Future<void> loadUserInfo() async {
    try {
      Map<String, dynamic> userInfo = await apiService.getUserInfo();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedImagePath = prefs.getString('profile_image_path');

      setState(() {
        userName = userInfo['name'];
        userNumero = userInfo['numero'];
        if (savedImagePath != null && savedImagePath.isNotEmpty) {
          _imageFile = XFile(savedImagePath);
        }
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
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Choisissez une source'),
            actions: <Widget>[
              TextButton(
                child: Text('Caméra'),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              TextButton(
                child: Text('Galerie'),
                onPressed: () {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          );
        },
      );

      if (source != null) {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _imageFile = pickedFile;
          });
          await _saveImage(pickedFile.path);
        }
      }
    } catch (e) {
      print('Erreur lors du choix de l\'image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du choix de l\'image')),
      );
    }
  }

  Future<void> _saveImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Utilisateur', style: TextStyle(fontSize: 12)),
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
              userName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              userNumero,
              style: TextStyle(
                fontSize: 12,
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
                    await apiService.archiveUser();
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
          title: Text('Déconnexion', style: TextStyle(fontSize: 12)),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?', style: TextStyle(fontSize: 12)),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler', style: TextStyle(fontSize: 12)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirmer', style: TextStyle(fontSize: 12)),
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
          title: Text('Supprimer le Profil', style: TextStyle(fontSize: 12)),
          content: Text(
              'Êtes-vous sûr de vouloir supprimer votre profil ? Cette action est irréversible.',
              style: TextStyle(fontSize: 12)),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler', style: TextStyle(fontSize: 12)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Confirmer', style: TextStyle(fontSize: 12)),
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
      title: Text(title, style: TextStyle(fontSize: 12)),
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
          Share.share(
            'Découvrez cette application incroyable ! Téléchargez-la depuis ce lien : https://lien-vers-votre-application.com',
            subject: 'Découvrez cette application !',
          );
        } else if (action != null) {
          action();
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
