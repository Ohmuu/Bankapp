import 'package:bankapp/components/action_grid.dart';
import 'package:bankapp/components/bank_card.dart';
import 'package:bankapp/components/header_section.dart';
import 'package:bankapp/components/transaction_history_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bankapp/components/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        setState(() {
          _currentIndex = index;
        });
        break;
      case 1:
        setState(() {
          _currentIndex = index;
        });
        break;
      case 2:
        Navigator.pushNamed(context, '/qr_payment_page');
        setState(() {
          _currentIndex = index;
        });
        break;
      case 3:
        setState(() {
          _currentIndex = index;
        });
        break;
      case 4:
        setState(() {
          _currentIndex = index;
        });
        break;
    }
  }

  //Single function to fectch user data
  Future<Map<String, dynamic>?> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    //fecth document current user's ID
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    //Future builder to fetch user data once
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        //hadle loading stete
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: CircularProgressIndicator(color: Color(0xFF16213E)),
            ),
          );
        }
        //hadle error
        if (snapshot.hasError ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          const fallbackName = 'User';
          const fallbackBalance = 0.0;
          const fallbackCard = 'xxx';
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
          }

          //render UI with fallback data
          return buildContent(
            name: fallbackName,
            balance: fallbackBalance,
            cardNumber: fallbackCard,
          );
        }

        final userData = snapshot.data!;
        print(userData);
        final name = userData['name'] ?? 'User';
        final balance =
            (userData['account_balance'] as num?)?.toDouble() ?? 0.0;
        final cardNumber = userData['card_number_suffix'] ?? 'xxx';

        return buildContent(
          name: name,
          balance: balance,
          cardNumber: cardNumber,
        );
      },
    );
  }

  Widget buildContent({
    required String name,
    required double balance,
    required String cardNumber,
  }) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HeaderSection(name: name),
              BankCard(name: name, balance: balance, cardNumber: cardNumber),
              ActionGrid(),
              TransactionHistorySection(),
              SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomNavbar(
        currentIndex: _currentIndex,
        onItemTapped: _onItemTapped,
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _onItemTapped(2),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
