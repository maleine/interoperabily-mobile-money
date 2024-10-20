import 'package:flutter/material.dart';
import 'package:interoperabilite/Api/ApiService.dart'; // Importer votre ApiService
import 'package:interoperabilite/widgets/colors.dart'; // Importer votre page de couleurs

class OtpVerificationPage extends StatefulWidget {
  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final ApiService apiService = ApiService(); // Créer une instance d'ApiService
  late String phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    phoneNumber = ModalRoute.of(context)!.settings.arguments as String;
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text).join('');
    if (otp.length == 6) {
      try {
        await apiService.verifyOtpPassword(phoneNumber, otp);
        // Redirige vers PasswordReset si la vérification réussit
        Navigator.of(context).pushNamed('/PasswordReset', arguments: phoneNumber);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())), // Affiche le message d'erreur spécifique
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer un code OTP valide de 6 chiffres.')),
      );
    }
  }

  Widget _buildOtpInput() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 40,
          child: TextField(
            controller: _otpControllers[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8), // Coins arrondis
              ),
              filled: true,
              fillColor: Colors.white, // Couleur de fond des champs
              hintText: '', // Pas de texte d'indice
            ),
            // Suppression de maxLength pour éviter les compteurs
            onChanged: (value) {
              // Se déplacer vers le champ suivant si le champ actuel est rempli
              if (value.length == 1 && index < 5) {
                FocusScope.of(context).nextFocus();
              }
              // Se déplacer vers le champ précédent si le champ actuel est vide
              if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vérification OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centre le contenu
          children: [
            Text('Un OTP a été envoyé à $phoneNumber', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            // Ajoutez une image centrée ici
            Image.asset('assets/images/otp1.png', height: 200), // Assurez-vous de remplacer 'assets/images/otp1.png' par votre image
            SizedBox(height: 20),
            _buildOtpInput(), // Champs de saisie OTP
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verifyOtp,
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
                  child: Text('Vérifier OTP', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
