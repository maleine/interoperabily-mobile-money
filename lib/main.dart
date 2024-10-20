import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:interoperabilite/MotDePasseOublie.dart';
import 'package:interoperabilite/OTPScreen.dart';
import 'package:interoperabilite/OtpVerification.dart';
import 'package:interoperabilite/PasswordReset.dart';
import 'package:interoperabilite/TransactionPage.dart';
import 'package:interoperabilite/profilUtilisateur.dart';
import 'connexion.dart';
import 'inscription.dart';
import 'interoperabilityPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCgSquBmcYb_9Rki5sF3fOSY1shp9Anv5A",
      appId: "1:89148371108:android:f1d236d01d257cba8b7631",
      messagingSenderId: "89148371108",
      projectId: "flutterotp-5862d",
      storageBucket: "flutterotp-5862d.appspot.com",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _movementAnimation;
  late Animation<double> _opacityAnimation;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _showTransMoneyText = false;

  @override
  void initState() {
    super.initState();

    // Initialisation de l'animation avec une durée de 15 secondes
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    // Animation de mouvement
    _movementAnimation = Tween<double>(begin: -200, end: 600).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Animation d'opacité
    _opacityAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Démarrer l'animation
    _controller.forward();

    // Afficher le texte "TransMoney" après 15 secondes
    Future.delayed(const Duration(seconds: 15), () {
      setState(() {
        _showTransMoneyText = true;
      });

      // Rediriger vers la page de connexion après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        _navigatorKey.currentState?.pushReplacement(
          MaterialPageRoute(builder: (context) => Connexion()),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fonction pour construire plusieurs icônes animées
  Widget _buildAnimatedIcons() {
    return Stack(
      children: List.generate(10, (index) {
        final double size = (index + 1) * 40.0;
        final double left = (index * 40.0) % 300;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Positioned(
              top: _movementAnimation.value + (index * 60.0),
              left: left,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Icon(
                  Icons.money,
                  size: size,
                  color: Colors.primaries[index % Colors.primaries.length]
                      .withOpacity(0.7),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Fonction pour afficher le texte animé "TransMoney"
  Widget _buildAnimatedText() {
    return Center(
      child: AnimatedOpacity(
        opacity: _showTransMoneyText ? 1.0 : 0.0,
        duration: const Duration(seconds: 2),
        child: Text(
          'TransMoney',
          style: TextStyle(
            fontSize: 40.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var numero;
    var otp;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: _navigatorKey,
      routes: {
        '/inscription': (context) => Inscription(),
        '/connexion': (context) => Connexion(),
        '/TransactionPage': (context) => TransactionPage(),
        '/interoperabilityPage': (context) => MobileMoneyInteroperabilityPage(userName: '',),
        '/profilUtilisateur': (context) => ProfilUtilisateur(),
        '/MotDePasseOublie': (context) => ForgetPassword(), // Ajoutez cette ligne
        '/PasswordReset': (context) => ResetPasswordPage(), // Ajoutez cette ligne

        '/OtpVerification': (context) =>  OtpVerificationPage(), // Ajoutez cette ligne
        '/OTPScreen': (context) => OtpScreen(numero: '', name: '', password: ''),
      },
      home: Scaffold(
        body: Stack(
          children: [
            // Dégradé de couleurs en arrière-plan
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF04748C),
                    Color(0xFF024A59),
                    Color(0xFF023540),
                    Color(0xFF012026),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Icônes d'argent animées
            _buildAnimatedIcons(),
            // Afficher le texte "TransMoney"
            if (_showTransMoneyText) _buildAnimatedText(),
          ],
        ),
      ),
    );
  }
}
