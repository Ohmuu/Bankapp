import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isLoading = false;

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.dispose();
  }

  String generateCardSuffix() {
    final random = Random();
    int number = random.nextInt(9000) + 1000;
    return number.toString();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    try {
      setState(() {
        isLoading = true;
      });

      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        _showSuccessSnackBar("Welcome back!");
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

        await userCredential.user!.updateDisplayName(nameController.text);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': emailController.text.trim(),
              'name': nameController.text.trim(),
              'account_balance': 0.0,
              'card_number_suffix': generateCardSuffix(),
              'created_at': FieldValue.serverTimestamp(),
            });

        _showSuccessSnackBar("Account created successfully!");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showErrorDialog("Invalid email address!");
      } else if (e.code == 'user-not-found') {
        _showErrorDialog("User not found!");
      } else if (e.code == 'wrong-password') {
        _showErrorDialog("Wrong password!");
      } else if (e.code == 'email-already-in-use') {
        _showErrorDialog("Email already in use!");
      } else {
        _showErrorDialog("Authentication failed!");
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog("Please enter your email!");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSuccessSnackBar("Password reset email sent!");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        _showErrorDialog("Invalid email address!");
      } else if (e.code == 'user-not-found') {
        _showErrorDialog("User not found!");
      } else {
        _showErrorDialog("Failed to send password reset email!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF533483), Color(0xFF16213E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 20),
                    _buildAuthCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(50),
      ),
      child: const Icon(Icons.account_balance, size: 80, color: Colors.white),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            Text(
              isLogin ? "Sign In" : "Sign Up",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF533483),
              ),
            ),
            const SizedBox(height: 16),

            if (!isLogin)
              _buildTextField(
                controller: nameController,
                labelText: "Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),

            if (!isLogin) const SizedBox(height: 16),

            _buildTextField(
              controller: emailController,
              labelText: "Email",
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: passwordController,
              labelText: "Password",
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your password";
                }
                return null;
              },
            ),

            if (isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  child: const Text("Forgot Password?"),
                ),
              ),

            const SizedBox(height: 10),

            _buildSubmitButton(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin
                      ? "Don't have an account?"
                      : "Already have an account?",
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
                  child: Text(isLogin ? "Sign Up" : "Sign In"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword && !isPasswordVisible,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordVisible = !isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF533483),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(isLogin ? "Sign In" : "Sign Up"),
    );
  }
}
