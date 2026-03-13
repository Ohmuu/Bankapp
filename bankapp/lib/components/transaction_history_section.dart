import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});
  Stream<QuerySnapshot> getTransactions(String uid) {
    return FirebaseFirestore.instance
        .collection('transactions')
        .where('user_id', isEqualTo: uid)
        .limit(5)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SizedBox.shrink();
    }

    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            buildSectionHeader(context),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: getTransactions(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: List.generate(
                      3,
                      (index) => const TransactionRowSkeleton(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  print('Transaction Error: ${snapshot.error}');
                  return Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Icon(Icons.error, color: Colors.grey, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading transactions',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        Icon(Icons.info, color: Colors.grey, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final transactions = snapshot.data!.docs;

                return Column(
                  children: transactions.take(5).map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return TransactionRow(
                      transaction: doc.id,
                      data: data['type'] ?? 'debit',
                      amount: (data['amount'] ?? 0).toDouble(),
                      timestamp: data['timestamp'] as Timestamp?,
                      description: data['description'] ?? 'Transaction',
                      category: data['category'] ?? 'general',
                      note: data['note'],
                      recipient: data['receiver_name'],
                      userId: data['user_id'],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

//Section header widget
Widget buildSectionHeader(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        "Transaction History",
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/transaction_page');
        },
        child: Text(
          "See All",
          style: TextStyle(fontSize: 14, color: Colors.blue),
        ),
      ),
    ],
  );
}

class TransactionRow extends StatelessWidget {
  final String transaction;
  final String data;
  final double amount;
  final Timestamp? timestamp;
  final String description;
  final String category;
  final String? note;
  final String? recipient;
  final String? userId;

  const TransactionRow({
    required this.transaction,
    required this.data,
    required this.amount,
    required this.timestamp,
    required this.description,
    required this.category,
    required this.note,
    required this.recipient,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isDebit = data == 'debit';
    final icon = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    final color = isDebit ? Colors.red : Colors.green;
    final amountText = isDebit
        ? '- ${amount.toStringAsFixed(2)}'
        : '+ ${amount.toStringAsFixed(2)}';
    final amountColor = isDebit ? Colors.red : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          buildIcon(icon, color),
          SizedBox(width: 15),
          buildDetail(description, category),
          Spacer(),
          Text(
            amountText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildIcon(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget buildDetail(String title, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }
}

//Single transaction row with skeleton loading effect
class TransactionRowSkeleton extends StatelessWidget {
  const TransactionRowSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildIconPlaceholder(),
        SizedBox(width: 15),

        buildDetailPlaceholder(),
        SkeletonContainer(width: 70, height: 15, radius: 4),
      ],
    );
  }
}

//Tracnsaction icon placeholder
Widget buildIconPlaceholder() {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withAlpha(8),
          spreadRadius: 1,
          blurRadius: 4,
          offset: Offset(0, 1),
        ),
      ],
    ),
    child: SkeletonContainer(width: 24, height: 24, radius: 4),
  );
}

//Transaction details placeholder(title category)
Widget buildDetailPlaceholder() {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonContainer(width: 120, height: 16, radius: 4),
        SizedBox(height: 5),
        SkeletonContainer(width: 80, height: 14, radius: 4),
      ],
    ),
  );
}

//Generic skeleton container for loading effect
class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonContainer({
    required this.width,
    required this.height,
    this.radius = 8,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
