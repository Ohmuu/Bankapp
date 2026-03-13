import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String name;
  const HeaderSection({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF533483), Color(0xFF16213E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // content overlay
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildTopBar(),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.lock, color: Colors.white),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Welcome", style: TextStyle(color: Colors.white)),
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Text(
                  "ED BANK",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),

        Row(
          children: [
            buildIconCircle(Icons.chat),
            buildIconCircle(Icons.notifications_outlined),
            buildIconCircleWithAction(Icons.logout, () async {
              await FirebaseAuth.instance.signOut();
            }),
          ],
        ),
      ],
    );
  }
}

Widget buildIconCircleWithAction(IconData icon, void Function()? onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.only(left: 10),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    ),
  );
}

Widget buildIconCircle(IconData icon) {
  return Container(
    margin: EdgeInsets.only(left: 10),
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: Colors.white),
  );
}
