import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:interoperabilite/widgets/colors.dart'; // Import des couleurs

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _formattedPhoneNumber; // Stocke le numéro de téléphone avec le préfixe

  Future<void> _submitPhoneNumber() async {
    if (_formattedPhoneNumber == null || _formattedPhoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de téléphone')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    ApiService apiService = ApiService();

    try {
      // Envoyer la demande de réinitialisation avec le numéro de téléphone formaté
      await apiService.requestPasswordReset(_formattedPhoneNumber!);

      setState(() {
        _isLoading = false;
      });

      // Redirection vers la page OTPScreen si l'envoi de l'OTP a réussi
      Navigator.pushNamed(context, '/OtpVerification', arguments: _formattedPhoneNumber);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'envoi du code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Entrez votre numéro de téléphone pour recevoir le code OTP',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
              initialCountryCode: 'SN', // Pays par défaut (Sénégal)
              onChanged: (phone) {
                // Stocker le numéro de téléphone complet (avec l'indicatif)
                _formattedPhoneNumber = phone.completeNumber;
                print('Numéro complet: $_formattedPhoneNumber');
              },
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _submitPhoneNumber,
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
                    'Envoyer le code',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
