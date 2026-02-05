import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; //
import 'package:cloud_firestore/cloud_firestore.dart'; //

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Handle Signup Logic
  Future<void> _handleSignUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1. Create user in Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        // 2. Store user details in Firestore 'users' collection
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'userid': uid,
          'created_at': FieldValue.serverTimestamp(), //
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Account created successfully!")),
          );
          // Navigate to Dashboard or Home
          // Navigator.pushReplacement(...)
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase specific errors
        String message = "Registration failed";
        if (e.code == 'weak-password') {
          message = "The password provided is too weak.";
        } else if (e.code == 'email-already-in-use') {
          message = "The account already exists for that email.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6FF),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                )
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.transparent,
                    backgroundImage: const AssetImage(
                      "assets/images/logo.png",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Create an Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  /// FULL NAME field now uses controller
                  _inputField(
                    icon: Icons.person,
                    hint: "Full Name",
                    controller: nameController,
                    validator: (val) => val == null || val.isEmpty ? "Name is required" : null,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email),
                      hintText: "Email Address",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      errorStyle: const TextStyle(fontSize: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Email is required";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return "Enter a valid email address";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  /// PASSWORD field now uses controller
                  _inputField(
                    icon: Icons.lock,
                    hint: "Password",
                    isPassword: true,
                    controller: passwordController,
                    validator: (val) => val != null && val.length < 6 ? "Password must be at least 6 characters" : null,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _handleSignUp, // Calls the Firebase logic
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 26, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text("Or sign up with", style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/google.png', height: 32, width: 32),
                      const SizedBox(width: 26),
                      _socialButton(Icons.apple),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(fontSize: 18)),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Updated helper to use TextFormField and handle controllers
  Widget _inputField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      child: Icon(icon, size: 28, color: Colors.black),
    );
  }
}
