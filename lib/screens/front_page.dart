import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'dashboard_screen.dart';
import 'signup_page.dart';





class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 22, 64, 123), // Primary Dark Navy Blue
              Color(0xFF081226), // Deep Background
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // 🔹 LOGO (Transparent PNG)
              Image.asset(
                'assets/images/logo.png',
                height: 350,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 14),

              // 🔹 APP NAME
              // const Text(
              //   "TRACKFLOW",
              //   style: TextStyle(
              //     fontSize: 28,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //     letterSpacing: 1.2,
              //   ),
              // ),

              const SizedBox(height: 8),

              // 🔹 TAGLINE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Track today’s decisions before they become tomorrow’s debt",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white70,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 LOGIN BUTTON
              SizedBox(
                width: 260,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DashboardScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 14),


              // 🔹 SIGN UP BUTTON (Outline)
              SizedBox(
                width: 260,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPage(),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 🔹 CONTINUE WITH GOOGLE
              Container(
                width: 260,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child:Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/google.png',
                            height: 22,
                            width: 22,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Continue with Google",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 30),

              // 🔹 BOTTOM TEXT
              const Text(
                "New user? Sign up for Quick Onboarding.",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OnboardingScreen(),
                    ),
                  );
                },
                child: const Text("Get Started"),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
