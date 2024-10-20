import 'package:http/http.dart' as http;
import 'dart:convert';

// Remplacez ces variables par vos propres informations de sandbox
const String sandboxBaseUrl = 'https://api.sandbox.orange-sonatel.com';
const String clientId = '8b118ae1-823f-4b27-ab55-06734b683d24';
const String clientSecret = 'eb10854d-4ab1-4ccf-98a7-3d6921d969e8';

Future<String?> authenticate() async {
  final response = await http.post(
    Uri.parse('$sandboxBaseUrl/oauth/token'),
    headers: <String, String>{
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'grant_type': 'client_credentials',
      'client_id': clientId,
      'client_secret': clientSecret,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['access_token'];
  } else {
    print('Failed to authenticate: ${response.reasonPhrase}');
    return null;
  }
}

Future<void> makePayment(String amount, String phoneNumber) async {
  final accessToken = await authenticate();
  if (accessToken == null) {
    print('Authentication failed.');
    return;
  }

  final response = await http.post(
    Uri.parse('$sandboxBaseUrl/v1/transactions'),
    headers: <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, dynamic>{
      'amount': amount,
      'phoneNumber': phoneNumber,
      // Pas de `merchantId` dans ce cas
    }),
  );

  if (response.statusCode == 200) {
    print('Payment successful: ${response.body}');
  } else {
    print('Payment failed: ${response.reasonPhrase}');
  }
}
