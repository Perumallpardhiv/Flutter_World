import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_firebase/pages/HomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  // This is used for signingIn to account with UserCredential
  FirebaseAuth auth = FirebaseAuth.instance;

  // creating a variable called storage which stores token
  final storage = new FlutterSecureStorage();

  Future<void> googleSignIn(BuildContext context) async {
    try {
      // pop up all google accounts in our phone
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      // checks wheather we selected any account or not
      if (googleSignInAccount != null) {
        // Stores selected account details in another variable
        GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        // takes required info of selected account from above created variable
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        try {
          // Here signIn with the details of account taken in above credential variable
          UserCredential userCredential = await auth.signInWithCredential(credential);

          // Stores token in flutter secure storage
          storeTokenAndData(userCredential);

          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => homePage()),
              (route) => false);
        } catch (e) {
          final snackbar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        }
      } else {
        final snackbar = SnackBar(content: Text("Not Able to sign In"));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      }
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }


  // method for storing flutter token
  Future<void> storeTokenAndData(UserCredential userCredential) async {
    // await storage.write(
    //     key: "token", value: userCredential.credential?.token.toString());
    await storage.write(
        key: "userCredential", value: userCredential.toString());
  }

  // method for checking token, used in main.dart for finding which is in currentPage variable
  Future<String?> getToken() async {
    return await storage.read(key: "userCredential");
  }

  // logout functionality
  Future<void> logout(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await auth.signOut();
      await storage.delete(key: "userCredential");
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }


  // sending and verifing the otp sent to given mobile number
  Future<void> verifyPhoneNumber(String phoneNumber, BuildContext context, Function setData) async {

    PhoneVerificationCompleted verificationCompleted = (PhoneAuthCredential phoneAuthCredential) async {
      showSnakeBar(context, "Verification Completed");
    };

    PhoneVerificationFailed verificationFailed = (FirebaseAuthException exception) {
      showSnakeBar(context, exception.toString());
    };

    PhoneCodeSent codeSent = (String verificationID, [int? forceResendingtoken]) {
      showSnakeBar(context, "Verification Code sent on the phone number");
      setData(verificationID);
    };

    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (String verificationID) {
      showSnakeBar(context, "Time Out");
    };

    try {
      await auth.verifyPhoneNumber(
        timeout: Duration(seconds: 60),
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
    } catch (e) {
      showSnakeBar(context, e.toString());
    }
  }

  Future<void> signInwithPhoneNumber (String verificationId, String smsCode, BuildContext context) async {
    try{
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await auth.signInWithCredential(credential);
      
      storeTokenAndData(userCredential);
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => homePage()),
        (route) => false);

        showSnakeBar(context, "logged In");
    }
    catch(e){
      showSnakeBar(context, e.toString());
    }
  }

  void showSnakeBar (BuildContext context, String text) {
    final snackbar = SnackBar(content: Text(text));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
