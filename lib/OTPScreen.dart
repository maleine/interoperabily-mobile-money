import 'package:flutter/material.dart';
import 'Api/ApiService.dart';

class OtpScreen extends StatefulWidget {
  final String numero;
  final String name;
  final String password;

  OtpScreen({
    required this.numero,
    required this.name,
    required this.password,
  });

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final ApiService apiService = ApiService();

  void _verifyOtp() async {
    String otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar('Veuillez entrer l\'OTP');
      return;
    }

    if (otp.length != 6 || int.tryParse(otp) == null) {
      _showSnackBar('L\'OTP doit contenir exactement 6 chiffres');
      return;
    }

    try {
      var response = await apiService.verifyOtp(widget.numero, otp, name: widget.name, password: widget.password);
      _showSnackBar('OTP validé avec succès !');

      // Redirection vers la page d'interopérabilité après validation réussie
      Navigator.pushReplacementNamed(context, '/connexion');
    } catch (e) {
      _showSnackBar('Erreur lors de la validation de l\'OTP : ${e.toString()}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Validation de l\'OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _otpController,
              decoration: InputDecoration(labelText: 'Entrez votre code OTP'),
              keyboardType: TextInputType.number,
              maxLength: 6, // Limite le champ à 6 chiffres
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
              child: Text('Valider l\'OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
