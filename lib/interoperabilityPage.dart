import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:interoperabilite/widgets/colors.dart';
import 'inscription.dart';
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
    {'name': 'Wave', 'image': 'assets/images/wave1.png'},
    {'name': 'Orange Money', 'image': 'assets/images/orange-money.png'},
  ];

  @override
  void initState() {
    super.initState();
    // Met à jour le champ "Montant reçu" lorsque le champ "Montant à envoyer" change
    _amountController.addListener(() {
      final amountText = _amountController.text;
      final amount = double.tryParse(amountText) ?? 0;
      final receivedAmount = roundUp(amount * 0.99); // Applique l'arrondi
      _receivedAmountController.text = receivedAmount.toStringAsFixed(2);
    });
  }


  // Fonction d'arrondi
  double roundUp(double value) {
    return (value / 1000).ceil() * 1000; // Arrondi à la dizaine supérieure
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
                  onPressed: () {
                    // Action du bouton d'envoi
                  },
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
