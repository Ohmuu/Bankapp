import 'package:flutter/material.dart';

class TransactionHistorySection extends StatelessWidget {
  const TransactionHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.only(top: 4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            buildSectionHeader(context),
            SizedBox(height: 10),
            Column(children: List.generate(5, (index) => TransactionRow())),
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

//Single transaction row with skeleton loading effect
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key});
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
