import 'package:flutter/material.dart';

Color darkBlue = Color(0xFF16213E);
Color darkPurple = Color(0xFF533483);

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  const CustomNavbar({
    Key? key,
    required this.currentIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.grey, blurRadius: 10, offset: Offset(0, -2)),
        ],
      ),
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 0,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.account_balance, "Account", 1),
              const SizedBox(width: 40),
              _buildNavItem(Icons.folder, "Apply", 3),
              _buildNavItem(Icons.more_horiz, "More", 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = currentIndex == index;
    final color = isSelected ? Color(0xFF533483) : Colors.grey;
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomFloatingActionButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 65,
      height: 65,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [darkBlue, darkPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: darkPurple, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(Icons.qr_code, size: 32, color: Colors.white),
      ),
    );
  }
}
