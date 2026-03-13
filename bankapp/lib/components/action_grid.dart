import 'package:bankapp/components/action_item.dart';
import 'package:flutter/material.dart';

class ActionGrid extends StatelessWidget {
  const ActionGrid({super.key});

  List<ActionItem> get actionItems => [
    ActionItem(
      icon: Icons.sync_alt,
      label: "Transfer",
      color: Color(0xFF16213E),
    ),
    ActionItem(
      icon: Icons.wallet_outlined,
      label: "Payment",
      color: Color(0xFF16213E),
    ),
    ActionItem(
      icon: Icons.shopping_cart,
      label: "Shop",
      color: Color(0xFF16213E),
    ),
    ActionItem(icon: Icons.apps, label: "Others", color: Color(0xFF16213E)),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What would you like to do today",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
              children: actionItems
                  .map((item) => ActionButton(item: item))
                  .toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

//induvidual action item widget
class ActionButton extends StatelessWidget {
  final ActionItem item;

  const ActionButton({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print("${item.label} tapped");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, color: item.color, size: 28),
            SizedBox(height: 8),
            Text(item.label, style: TextStyle(color: item.color, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
