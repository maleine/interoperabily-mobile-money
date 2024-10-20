import 'package:flutter/material.dart';

// Classe de modèle pour une transaction
class Transaction {
  final String fromNumber;
  final String toNumber;
  final double amount;
  final double fees;
  final DateTime paymentDate;
  final String transferOperator;
  final String receivingOperator;

  Transaction({
    required this.fromNumber,
    required this.toNumber,
    required this.amount,
    required this.fees,
    required this.paymentDate,
    required this.transferOperator,
    required this.receivingOperator,
  });
}

class TransactionPage extends StatelessWidget {
  // Liste de transactions (vous pouvez les récupérer depuis une base de données)
  final List<Transaction> transactions = [
    Transaction(
      fromNumber: '+221771234567',
      toNumber: '+221776543210',
      amount: 10000,
      fees: 500,
      paymentDate: DateTime.now(),
      transferOperator: 'Orange Money',
      receivingOperator: 'Wave',
    ),
    Transaction(
      fromNumber: '+221771234567',
      toNumber: '+221776543210',
      amount: 15000,
      fees: 600,
      paymentDate: DateTime.now(),
      transferOperator: 'Free Money',
      receivingOperator: 'Wave',
    ),
    // Ajoutez d'autres transactions ici
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Transactions'),
        backgroundColor: Color(0xFF04748C),
      ),
      body: Container(
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
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: ListTile(
                title: Text(
                  'De: ${transaction.fromNumber} À: ${transaction.toNumber}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Montant: ${transaction.amount.toStringAsFixed(2)} FCFA'),
                    Text('Frais: ${transaction.fees.toStringAsFixed(2)} FCFA'),
                    Text('Date de paiement: ${transaction.paymentDate.toString().substring(0, 16)}'),
                    Text('Opérateur de transfert: ${transaction.transferOperator}'),
                    Text('Opérateur de réception: ${transaction.receivingOperator}'),
                  ],
                ),
                trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: TransactionPage(),
));
