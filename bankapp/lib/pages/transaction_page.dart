import 'package:bankapp/pages/qr_payment_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  final Color darkBlue = Color(0xFF16213E);
  final Color darkPurple = Color(0xFF533483);
  TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  String filterType = 'all';

  Stream<QuerySnapshot> getTransactions(String uid) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: uid);
    if (filterType != 'all') {
      query = query.where('type', isEqualTo: filterType);
    }
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Transactions History"),
            backgroundColor: widget.darkBlue,
            foregroundColor: Colors.white,
          ),
          body: Center(child: Text("No user logged in")),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Transactions History"),
          backgroundColor: widget.darkBlue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            buildfilerButton(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: getTransactions(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error, color: Colors.red, size: 50),
                          SizedBox(height: 10),
                          Text("Error: ${snapshot.error}"),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.grey,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text("No transactions found"),
                        ],
                      ),
                    );
                  }
                  final transactions = snapshot.data!.docs;
                  // sort transaction by timestamp (newest first)
                  transactions.sort((a, b) {
                    final timestampA = a['timestamp'] as Timestamp?;
                    final timestampB = b['timestamp'] as Timestamp?;

                    if (timestampA == null) return 1;
                    if (timestampB == null) return -1;
                    return timestampB.compareTo(timestampA);
                  });

                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      final data = transaction.data() as Map<String, dynamic>;

                      final type = data['type'] ?? 'debit';

                      String description;

                      if (type == 'debit') {
                        description = 'Sent to ${data['receiver_name'] ?? ''}';
                      } else {
                        description =
                            'Received from ${data['sender_name'] ?? ''}';
                      }
                      return TransactionCard(
                        transaction: transaction.id,
                        data: data['type'] ?? 'debit',
                        amount: data['amount'] ?? 0,
                        timestamp: data['timestamp'] as Timestamp?,
                        description: data['description'] ?? 'Transaction',
                        category: data['category'] ?? 'general',
                        note: data['note'],
                        recipient: data['receiver_name'],
                        sender: data['sender_name'],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildfilerButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        children: [
          Expanded(child: FilterButton('All', 'all')),
          SizedBox(width: 10),
          Expanded(child: FilterButton('Sent', 'debit')),
          SizedBox(width: 10),
          Expanded(child: FilterButton('Received', 'credit')),
        ],
      ),
    );
  }

  Widget FilterButton(String label, String value) {
    final isSelected = filterType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          filterType = value;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? widget.darkPurple : Colors.white,
          border: Border.all(color: widget.darkPurple),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          textAlign: TextAlign.center,
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final String transaction;
  final String data;
  final double amount;
  final Timestamp? timestamp;
  final String description;
  final String category;
  final String? note;
  final String? recipient;
  final String? sender;
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.data,
    required this.amount,
    required this.timestamp,
    required this.description,
    required this.category,
    this.note,
    this.recipient,
    this.sender,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = data == 'debit';
    final icon = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isDebit ? Colors.red : Colors.green;
    final amountText = '${isDebit ? '-' : '+'}฿${amount.toStringAsFixed(2)}';
    final amountColor = isDebit ? Colors.red : Colors.green;

    String formatedDate = 'Unknown Date';

    if (timestamp != null) {
      final date = timestamp!.toDate(); // แปลง Timestamp → DateTime
      formatedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _showTransactionDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      formatedDate,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    if (note != null && note!.isNotEmpty)
                      Text(
                        'Note: $note!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),
              Text(
                amountText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context) {
    final isDebit = data == 'debit';
    final icon = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isDebit ? Colors.red : Colors.green;
    final amountText = '${isDebit ? '-' : '+'}฿${amount.toStringAsFixed(2)}';
    final amountColor = isDebit ? Colors.red : Colors.green;

    String formatedDate = 'Unknown Date';

    if (timestamp != null) {
      final date = timestamp!.toDate(); // แปลง Timestamp → DateTime
      formatedDate = DateFormat('dd MMM yyyy, hh:mm a').format(date);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                SizedBox(height: 16),
                // icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),

                // amount
                Text(
                  amountText,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),

                //status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    data,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ),

                //Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Transactoion Type',
                        data == 'debit' ? 'Sent' : 'Received',
                        Icon(Icons.swap_horiz),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      _buildDetailRow(
                        'Description',
                        description,
                        Icon(Icons.description),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      _buildDetailRow('Amount', amountText, Icon(Icons.money)),
                      const Divider(height: 16, color: Colors.grey),
                      _buildDetailRow(
                        'Date',
                        formatedDate,
                        Icon(Icons.date_range),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      _buildDetailRow(
                        'Sender',
                        sender ?? 'N/A',
                        Icon(Icons.person),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      _buildDetailRow(
                        'Recipient',
                        recipient ?? 'N/A',
                        Icon(Icons.person),
                      ),
                      const Divider(height: 16, color: Colors.grey),
                      if (note != null && note!.isNotEmpty)
                        _buildDetailRow(
                          'Note',
                          note ?? 'N/A',
                          Icon(Icons.note),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDetailRow(String label, String value, Icon icon) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        icon,
        SizedBox(width: 8),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Text(value),
      ],
    ),
  );
}
