import 'package:bankapp/components/auth_screen.dart';
import 'package:bankapp/firebase_options.dart';
import 'package:bankapp/pages/account_page.dart';
import 'package:bankapp/pages/change_password_page.dart';
import 'package:bankapp/pages/home_page.dart';
import 'package:bankapp/pages/qr_payment_page.dart';
import 'package:bankapp/pages/security_page.dart';
import 'package:bankapp/pages/transaction_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
      routes: {
        '/home_page': (context) => HomePage(),
        '/qr_payment_page': (context) => QrPaymentPage(),
        '/transaction_page': (context) => TransactionPage(
          transactionId: 'TXN ${DateTime.now().millisecondsSinceEpoch}_sender',
        ),
        '/account_page': (context) => AccountPage(),
        '/security_page': (context) => SecurityPage(),
        '/change_password_page': (context) => ChangePasswordPage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return HomePage();
        }
        return AuthScreen();
      },
    );
  }
}
