import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interoperabilite/widgets/colors.dart';
import 'package:interoperabilite/Api/ApiService.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:interoperabilite/Api/Orange money.dart';

class MobileMoneyInteroperabilityPage extends StatefulWidget {
  final String userName;
  const MobileMoneyInteroperabilityPage({super.key, required this.userName});

  @override
  _MobileMoneyInteroperabilityPageState createState() =>
      _MobileMoneyInteroperabilityPageState();
}

class _MobileMoneyInteroperabilityPageState
    extends State<MobileMoneyInteroperabilityPage> {
  String phoneNumber = '';
  String? _selectedOperator;
  Map<String, String>? _selectedOperatorDetails;
  String? _selectedSecondaryOperator;
  Map<String, String>? _selectedSecondaryOperatorDetails;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receivedAmountController =
  TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _secondaryPhoneController =
  TextEditingController();

  final List<Map<String, String>> _operators = [
    {'name': 'wave', 'image': 'assets/images/wave1.png'},
    {'name': 'orange ', 'image': 'assets/images/orange-money.png'},
  ];

  ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // Met à jour le champ "Montant reçu" lorsque le champ "Montant à envoyer" change
    _amountController.addListener(() {
      // Lorsque le montant à envoyer change, on met simplement à jour le montant reçu
      final amountText = _amountController.text;
      final amount = double.tryParse(amountText) ?? 0;
      _receivedAmountController.text = amount.toStringAsFixed(2); // Montant reçu = Montant envoyé
    });
  }

  Future<void> _sendMoney() async {
    // Vérifiez si les champs nécessaires sont remplis
    if (_selectedOperator == null || _selectedSecondaryOperator == null || phoneNumber.isEmpty) {
      _showErrorDialog('Veuillez remplir tous les champs nécessaires.');
      return;
    }

    final fromOperator = _selectedOperator!;
    final toOperator = _selectedSecondaryOperator!;
    final fromPhone = _phoneController.text;
    final toPhone = _secondaryPhoneController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;

    // Affichez les valeurs saisies dans la console pour déboguer
    print("Opérateur de départ : $fromOperator");
    print("Opérateur de destination : $toOperator");
    print("Numéro de téléphone de l'utilisateur : $fromPhone");
    print("Numéro de téléphone du destinataire : $toPhone");
    print("Montant de la transaction : $amount");

    // Vérification du montant minimum
    if (amount < 500) {
      _showErrorDialog('Le montant minimum est de 500.');
      return;
    }

    try {
      // Appel à l'API d'Orange Money pour effectuer le transfert
      final response = await apiService.transaction(
        fromOperator: fromOperator,
        toOperator: toOperator,
        fromPhone: fromPhone,
        toPhone: toPhone,
        amount: amount,
      );

      // Affichez la réponse complète pour voir ce que l'API renvoie
      print("Réponse de l'API : $response");

      if (response['status'] == 'success') {
        // Si la réponse est réussie, affichez un message de succès
        _showSuccessDialog('Transaction réussie!');
      } else {
        // Si la réponse contient un statut autre que 'success', affichez l'erreur renvoyée par l'API
        String errorMessage = response['error'] ?? 'Erreur inconnue';
        print("Erreur API: $errorMessage");  // Affichage de l'erreur dans la console
        _showErrorDialog('Erreur lors du traitement de la transaction: $errorMessage');
      }
    } catch (e, stackTrace) {
      // Si une exception est levée pendant l'appel API, affichez l'erreur spécifique dans la console
      print("Exception levée: $e");
      print("Stack trace: $stackTrace");

      // Affiche un message d'erreur générique à l'utilisateur
      _showErrorDialog('Une erreur est survenue. Veuillez réessayer.');
    }
  }






// Fonction pour afficher un dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Fonction pour afficher un dialogue de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final String userName =
    ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: SingleChildScrollView( // Scrolling enabled
        child: SafeArea(
          child: Column(
            children: [
              // Conteneur principal avec le dégradé
              Container(
                width: screenWidth,
                height: 140,
                decoration: BoxDecoration(
                  gradient: ColorTheme.focusedGradient,
                  borderRadius: BorderRadius.zero,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.list, color: Colors.white),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pushNamed(context, '/TransactionPage');
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.person, color: Colors.white),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pushNamed(
                              context, '/profilUtilisateur',
                              arguments: userName);
                        },
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Bienvenue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ' $userName',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Premier ensemble de liste déroulante et champ de texte
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.9, // Définir la largeur ici
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedOperator,
                          hint: _selectedOperatorDetails != null
                              ? ClipOval(
                            child: Image.asset(
                              _selectedOperatorDetails!['image']!,
                              fit: BoxFit.contain, // Changer à contain
                              width: 32,
                              height: 32,
                            ),
                          )
                              : ClipOval(
                            child: Image.asset(
                              'assets/images/wave1.png', // Image par défaut
                              fit: BoxFit.contain, // Changer à contain
                              width: 32,
                              height: 32,
                            ),
                          ),
                          items: _operators.map((operator) {
                            return DropdownMenuItem<String>(
                              value: operator['name'],
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      operator['image']!,
                                      fit: BoxFit.contain, // Changer à contain
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Espacement
                                  Text(
                                    operator['name']!,
                                    style: TextStyle(fontSize: 12), // Ajuste la taille ici
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedOperator = newValue;
                              _selectedOperatorDetails =
                                  _operators.firstWhere(
                                          (op) => op['name'] == newValue);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Espacement entre l'opérateur et le champ de téléphone
                    IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Numéro de téléphone',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      initialCountryCode: 'SN',
                      onChanged: (phone) {
                        setState(() {
                          phoneNumber = phone.completeNumber;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Champ de saisie du montant et texte "minimum 500"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey, width: 1),
                        ),
                      ),
                      child: TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Montant à envoyer',
                          hintStyle: TextStyle(fontSize: 12),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Minimum 500',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ),
              ),

              // Icône centré avec le dégradé de couleur
              Container(
                padding: const EdgeInsets.all(14),
                width: screenWidth,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: ColorTheme.focusedGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.swap_horiz,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),

              // Deuxième ensemble de liste déroulante et champ de texte
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: screenWidth * 0.9, // Définir la largeur ici
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSecondaryOperator,
                          hint: _selectedSecondaryOperatorDetails != null
                              ? ClipOval(
                            child: Image.asset(
                              _selectedSecondaryOperatorDetails!['image']!,
                              fit: BoxFit.contain, // Changer à contain
                              width: 32,
                              height: 32,
                            ),
                          )
                              : ClipOval(
                            child: Image.asset(
                              'assets/images/orange-money.png', // Image par défaut
                              fit: BoxFit.contain, // Changer à contain
                              width: 32,
                              height: 32,
                            ),
                          ),
                          items: _operators.map((operator) {
                            return DropdownMenuItem<String>(
                              value: operator['name'],
                              child: Row(
                                children: [
                                  ClipOval(
                                    child: Image.asset(
                                      operator['image']!,
                                      fit: BoxFit.contain, // Changer à contain
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  const SizedBox(width: 8), // Espacement
                                  Text(
                                    operator['name']!,
                                    style: TextStyle(fontSize: 12), // Ajuste la taille ici
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSecondaryOperator = newValue;
                              _selectedSecondaryOperatorDetails =
                                  _operators.firstWhere(
                                          (op) => op['name'] == newValue);
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8), // Espacement entre l'opérateur et le champ de téléphone
                    IntlPhoneField(
                      controller: _secondaryPhoneController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Numéro de téléphone',
                        hintStyle: TextStyle(fontSize: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 1.5,
                          ),
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      initialCountryCode: 'SN',
                      onChanged: (phone) {
                        setState(() {
                          phoneNumber = phone.completeNumber;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Champ de saisie du montant reçu
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: _receivedAmountController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Montant reçu',
                    hintStyle: TextStyle(fontSize: 12),
                  ),
                  keyboardType: TextInputType.number,
                  readOnly: true, // Rendre le champ en lecture seule
                ),
              ),

              // Bouton d'envoi avec dégradé
              // Bouton d'envoi avec dégradé
              Container(
                width: screenWidth * 0.8, // Ajuster la largeur du bouton (90% de la largeur de l'écran)
                decoration: BoxDecoration(
                  gradient: ColorTheme.focusedGradient, // Appliquer le dégradé
                  borderRadius: BorderRadius.circular(10), // Arrondir les coins
                ),
                child: ElevatedButton(
                  onPressed: _sendMoney
                    // Action du bouton d'envoi
                  ,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.transparent, // Rendre le fond transparent
                  ),
                  child: const Text(
                    'Envoyer',
                    style: TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
