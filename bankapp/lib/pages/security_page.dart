import 'package:flutter/material.dart';
import 'package:bankapp/pages/pin_setup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Color whitePurple = const Color(0xFF6F61C2);
final Color darkPurple = const Color(0xFF533483);

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool twoFactorAuth = false;
  bool biometricAuth = false;
  bool pinAuth = false;
  bool securityQuestion = false;

  @override
  void initState() {
    super.initState();
    _loadPinStatus();
  }

  Future<void> _loadPinStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pinAuth = prefs.getBool('pinAuth') ?? false;
    });
  }

  Future<void> _savePinToggle(bool value) async {
    if (value) {
      final prefs = await SharedPreferences.getInstance();
      final hasPin = prefs.getString('user_pin') != null;
      if (hasPin) {
        await prefs.setBool('pinAuth', value);
        setState(() {
          pinAuth = value;
        });
      } else {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PinSetupPage(isChangePin: false),
          ),
        );
        if (result == true) {
          setState(() {
            pinAuth = true;
          });
        }
      }
    } else {
      //Disable Pin
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pinAuth', false);
      setState(() {
        pinAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: whitePurple.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.security, color: darkPurple, size: 40),
                ),
              ),

              SizedBox(height: 20),
              Text(
                'Security Setting',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              buildSecurityOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSecurityOption() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          buildSecurityItems(
            icon: Icons.lock,
            iconColor: darkPurple,
            title: 'Change Password',
            subtitle: 'Update your password to ensure security',
            hasSwitch: false,
            onTap: () {
              Navigator.pushNamed(context, '/change_password_page');
            },
          ),
          Divider(indent: 20, endIndent: 20),
          buildSecurityItems(
            icon: Icons.pin,
            iconColor: darkPurple,
            title: 'PIN Security',
            subtitle: 'Set up your PIN code for quick access to your account',
            hasSwitch: true,
            switchValue: pinAuth,
            onSwitchChanged: _savePinToggle,
          ),
          if (pinAuth) ...[
            Divider(indent: 20, endIndent: 20),
            buildSecurityItems(
              icon: Icons.password,
              iconColor: darkPurple,
              title: 'Change PIN',
              subtitle: 'Update your PIN code for quick access to your account',
              hasSwitch: false,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinSetupPage(isChangePin: true),
                  ),
                );
                if (result == true) {
                  setState(() {
                    pinAuth = true;
                  });
                }
              },
            ),
          ],
          Divider(indent: 20, endIndent: 20),
          buildSecurityItems(
            icon: Icons.verified_user_outlined,
            iconColor: darkPurple,
            title: 'Two-Factor Authentication',
            subtitle: 'Enhance security with two-factor authentication',
            hasSwitch: true,
            switchValue: twoFactorAuth,
            onSwitchChanged: (value) {
              setState(() {
                twoFactorAuth = value;
              });
            },
          ),
          Divider(indent: 20, endIndent: 20),
          buildSecurityItems(
            icon: Icons.fingerprint,
            iconColor: darkPurple,
            title: 'Biometric Authentication',
            subtitle:
                'Enable biometric authentication for quick access to your account',
            hasSwitch: true,
            switchValue: biometricAuth,
            onSwitchChanged: (value) {
              setState(() {
                biometricAuth = value;
              });
            },
          ),
          Divider(indent: 20, endIndent: 20),
          buildSecurityItems(
            icon: Icons.quiz_outlined,
            iconColor: darkPurple,
            title: 'Security Questions',
            subtitle:
                'Set up your security questions for quick access to your account',
            hasSwitch: true,
            switchValue: securityQuestion,
            onSwitchChanged: (value) {
              setState(() {
                securityQuestion = value;
              });
            },
          ),
          Divider(indent: 20, endIndent: 20),
          buildSecurityItems(
            icon: Icons.history,
            iconColor: darkPurple,
            title: 'Login History',
            subtitle: 'View your login history',
            hasSwitch: false,
            //onTap()
          ),
        ],
      ),
    );
  }

  Widget buildSecurityItems({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool hasSwitch,
    bool switchValue = false,
    Function(bool)? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: hasSwitch ? null : onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 30),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            if (hasSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: darkPurple,
                activeTrackColor: darkPurple.withValues(alpha: 0.2),
                inactiveTrackColor: Colors.grey[300],
                inactiveThumbColor: Colors.grey[600],
              )
            else
              Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
