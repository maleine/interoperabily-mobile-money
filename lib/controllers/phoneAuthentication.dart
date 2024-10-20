import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PhoneAuthentication {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


//send OTP Code to Phone Number

  Future<void> sendOTPCode(String phoneNo, Function(String) onCodeSent) async {
    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 40),
      phoneNumber: phoneNo,
      verificationCompleted: (credential) {},
      verificationFailed: (e) {},
      codeSent: (verificationId, resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  // verify OTP Code

  Future<String> verifyOTPCode({
    required String verifyId,
    required String otp,
  }) async {
    try {
      PhoneAuthCredential authCredential = PhoneAuthProvider.credential(
        verificationId: verifyId,
        smsCode: otp,
      );
      final UserCredential userCredential =
      await _auth.signInWithCredential(authCredential);
      if (userCredential.user != null) {
        await storeNumber(userCredential.user!.phoneNumber!);
        return 'success';
      } else {
        return 'Error in OTP';
      }
    } catch (e) {
      return e.toString();
    }
  }

  // sign with Google Account



  //store userData

  Future<void> storeUserData(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
      });
    } catch (e) {
      e.toString();
    }
  }

//signout user
  Future<void> logOutUser() async {
    await _auth.signOut();
  }

//store phone number

  Future<void> storeNumber(String phoneNo) async {
    try {
      await _firestore.collection('users').doc(phoneNo).set({
        'phoneNumber': phoneNo,
      });
    } catch (e) {
      e.toString();
    }
  }
}