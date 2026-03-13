import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bankapp/components/bottom_nav_bar.dart';
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';

final Color darkBlue = Color(0xFF16213E);
final Color darkPurple = Color(0xFF533483);

class QrPaymentPage extends StatefulWidget {
  const QrPaymentPage({super.key});

  @override
  State<QrPaymentPage> createState() => _QrPaymentPageState();
}

class _QrPaymentPageState extends State<QrPaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    if (index == 2) {
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home_page');
        break;
      case 1:
        // Navigator.pushNamed(context, '/account_page');
        break;
      case 3:
        // Navigator.pushNamed(context, '/apply_page');
        break;
      case 4:
        // Navigator.pushNamed(context, '/more_page');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("QR Payment"),
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.qr_code), text: 'Payment'),
              Tab(icon: Icon(Icons.qr_code_scanner), text: 'Scan'),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: [
            Center(child: GenerateQrCode()),
            Center(child: ScanQrTab()),
          ],
        ),
        bottomNavigationBar: CustomNavbar(
          currentIndex: _selectedIndex,
          onItemTapped: _onNavItemTapped,
        ),
        floatingActionButton: CustomFloatingActionButton(onPressed: () => {}),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

//Tab 1 generate qr code using firebase data and qr flutter
class GenerateQrCode extends StatefulWidget {
  const GenerateQrCode({super.key});

  @override
  State<GenerateQrCode> createState() => _GenerateQrCodeState();
}

class _GenerateQrCodeState extends State<GenerateQrCode> {
  String? qrData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _generateQrCode();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    return doc.data();
  }

  void _generateQrCode() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final userData = await getUserData();
      if (userData == null) throw Exception("User data not found");

      // Create Qr data with only user data
      final qrPayload = {
        'userId': user.uid,
        'name': userData['name'],
        'accountNumber': userData['account_number'],
        'bankName': userData['bank_name'],
        'ifscCode': userData['ifsc_code'],
        'phoneNumber': userData['phone_number'],
        'email': userData['email'],
      };

      final qrDataString = json.encode(qrPayload);

      setState(() {
        qrData = qrDataString;
        isLoading = false;
      });
    } catch (e) {
      print("Error generating QR code: $e");
      setState(() {
        qrData = null;
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to generate QR code")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[200]!, Colors.grey[200]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(color: darkBlue)
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Icon(
                      Icons.account_circle_rounded,
                      size: 100,
                      color: darkBlue,
                    ),
                    FutureBuilder<Map<String, dynamic>?>(
                      future: getUserData(),
                      builder: (context, snapshot) {
                        final userName = snapshot.data?['name'] ?? 'User';
                        return Text(
                          userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Show QR Code to receive payments',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 30),
                      padding: EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: qrData != null
                          ? QrImageView(
                              data: qrData!,
                              size: 200,
                              version: QrVersions.auto,
                              eyeStyle: QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: darkBlue,
                              ),
                              dataModuleStyle: QrDataModuleStyle(
                                color: darkBlue,
                              ),
                            )
                          : SizedBox(
                              height: 200,
                              width: 200,
                              child: Center(
                                child: Text("Unable to generate QR Code"),
                              ),
                            ),
                    ),
                    SizedBox(height: 20),

                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.transparent,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info, color: darkBlue),
                          SizedBox(width: 10),
                          Text(
                            'Scan QR Code to make payment',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

//Tab 2 Scan Qr Code

class ScanQrTab extends StatefulWidget {
  const ScanQrTab({super.key});

  @override
  State<ScanQrTab> createState() => _ScanQrTabState();
}

class _ScanQrTabState extends State<ScanQrTab> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> proossingQrData(String qrData) async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });

    try {
      final data = json.decode(qrData) as Map<String, dynamic>;
      final receiverId = data['userId'] as String;
      final receiverName = data['name'] as String;

      //get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      if (currentUser.uid == receiverId) {
        throw Exception("You cannot pay yourself");
      }

      // Navigate  to payment comfirmation page
      if (!mounted) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentConfirmationPage(
            receiverId: receiverId,
            receiverName: receiverName,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pushReplacementNamed(context, '/home_page');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to process QR code: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty && !isProcessing) {
              final String? code = barcodes.first.rawValue;
              if (code != null) {
                proossingQrData(code);
              }
            }
          },
        ),

        // overlay scan frame
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: darkBlue, width: 2),
          ),
          child: Column(
            children: [
              Spacer(),
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Stack(
                    children: [
                      // top left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // top right
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // bottom left
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                              left: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // bottom right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                              right: BorderSide(
                                color: Colors.greenAccent,
                                width: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code, color: darkBlue),
                    Text(
                      "Scan QR Code to pay",
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Spacer(),
              if (isProcessing)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: darkBlue),
                      SizedBox(width: 10),
                      Text(
                        "Processing...",
                        style: TextStyle(
                          color: darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 20),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

//New payment confirmation page
class PaymentConfirmationPage extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const PaymentConfirmationPage({
    super.key,
    required this.receiverName,
    required this.receiverId,
  });

  @override
  State<PaymentConfirmationPage> createState() =>
      _PaymentConfirmationPageState();
}

class _PaymentConfirmationPageState extends State<PaymentConfirmationPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool isProcessing = false;
  double? _senderBalance;

  @override
  void initState() {
    super.initState();
    loadSenderBalance();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> loadSenderBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (mounted) {
      setState(() {
        _senderBalance = ((doc.data()!['account_balance'] ?? 0.0) as num)
            .toDouble();
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter an amount')));
      return;
    }

    final amount = double.parse(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    setState(() {
      isProcessing = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      await makePayment(
        senderUserId: user.uid,
        receiverId: widget.receiverId,
        amount: amount,
        note: _noteController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment successful!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed! ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> makePayment({
    required String senderUserId,
    required String receiverId,
    required double amount,
    required String note,
  }) async {
    final firestore = FirebaseFirestore.instance;

    //use batch write to update both accounts
    final batch = firestore.batch();

    final senderDoc = firestore.collection('users').doc(senderUserId);
    final receiverDoc = firestore.collection('users').doc(receiverId);

    //get current balances
    final senderSnapshot = await senderDoc.get();
    final receiverSnapshot = await receiverDoc.get();

    if (!senderSnapshot.exists || !receiverSnapshot.exists) {
      throw Exception('User not found');
    }

    final senderBalance =
        ((senderSnapshot.data()!['account_balance'] ?? 0.0) as num).toDouble();
    final receiverBalance =
        ((receiverSnapshot.data()!['account_balance'] ?? 0.0) as num)
            .toDouble();
    final senderName = senderSnapshot.data()?['name'] ?? 'User';
    final receiverName = receiverSnapshot.data()?['name'] ?? 'User';

    if (senderBalance < amount) {
      throw Exception('Insufficient balance');
    }

    //update balances
    batch.update(senderDoc, {'account_balance': senderBalance - amount});
    batch.update(receiverDoc, {'account_balance': receiverBalance + amount});

    //add transaction history
    final transactionId = firestore.collection('transactions').doc().id;
    final timestamp = FieldValue.serverTimestamp();

    batch.set(
      firestore.collection('transactions').doc(transactionId + 'sender'),
      {
        'sender_id': senderUserId,
        'type': 'debit',
        'description': 'QR Payment from ${receiverName}',
        'receiver_id': receiverId,
        'sender_name': senderName,
        'receiver_name': receiverName,
        'amount': amount,
        'note': note.isNotEmpty ? note : null,
        'timestamp': timestamp,
        'category': 'QR Payment',
      },
    );

    batch.set(
      firestore.collection('transactions').doc(transactionId + 'receiver'),
      {
        'sender_id': senderUserId,
        'type': 'credit',
        'sender_name': senderName,
        'receiver_name': receiverName,
        'description': 'QR Payment to ${senderName}',
        'amount': amount,
        'note': note.isNotEmpty ? note : null,
        'timestamp': timestamp,
        'category': 'QR Payment',
      },
    );

    //commit batch
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text(
            'Confirm Payment',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          backgroundColor: darkBlue,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Recipt Info Card
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pay to',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(width: 10),
                    Text(
                      widget.receiverName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              //Amount Input Card
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.black),

                      decoration: InputDecoration(
                        prefixText: '฿ ',
                        prefixStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),

                    SizedBox(height: 10),
                    if (_senderBalance != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Available Balance: ${_senderBalance!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    SizedBox(height: 30),
                    Text(
                      'Note (optional)',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: 'Enter note',
                        hintStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _confirmPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      disabledBackgroundColor: darkBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Confirm Payment',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              //Cancle Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkBlue,
                      disabledBackgroundColor: darkBlue.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
