import 'package:flutter/material.dart';
import 'front_page.dart';
import 'onboarding_screen.dart';
// import 'package:provider/provider.dart'; // theme ke liye
// import '../theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 38, // 👈 AppBar title font size
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 34, // 👈 settings icon size
            ),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // 🔹 PROFILE CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.blueAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 86, // 👈 profile image size
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 120, // 👈 profile icon size
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Vedant",
                    style: TextStyle(
                      fontSize: 38, // 👈 user name font size
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 6),

                  ElevatedButton(
                    onPressed: () {},
                    child: const Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 24, // 👈 edit button text size
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 STATS
          //  Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceAround,
          //     children: [
          //       _statCard("124", "Total Decisions"),
          //       _statCard("65", "Debt Score"),
          //     ],
          //   ), 

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statCard(
                "assets/images/exam.png",   // 👈 IMAGE ADDRESS
                "124",
                "Total Decisions",
              ),
              _statCard(
                "assets/images/speedometer.png",      // 👈 IMAGE ADDRESS
                "65",
                "Debt Score",
              ),
            ],
          ),


            const SizedBox(height: 20),

            // 🔹 SETTINGS LIST
            _tile(Icons.person, "Account Settings"),
            _tile(Icons.notifications, "Notifications"),

            // 🌙 THEME SWITCH (removed but reference kept)
            // SwitchListTile(
            //   value: themeProvider.isDark,
            //   onChanged: themeProvider.toggleTheme,
            //   title: const Text(
            //     "Dark Theme",
            //     style: TextStyle(fontSize: 14),
            //   ),
            //   secondary: const Icon(Icons.dark_mode),
            // ),

            _tile(Icons.lock, "Data & Privacy"),
            _tile(Icons.help, "Help & Support"),
            _tile(
                Icons.info,
                "About TrackFlow",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingScreen(),
                    ),
                  );
                },
              ),


            const SizedBox(height: 20),

            // 🔴 LOGOUT BUTTON
            OutlinedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FrontPage(),
                  ),
                  (route) => false, // 🔥 clears all previous screens
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 24, // 👈 logout button text size
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== STATS CARD =====================
  // static Widget _statCard(String value, String label) {
  //   return Container(
  //     padding: const EdgeInsets.all(12),
  //     width: 140,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(14),
  //       boxShadow: const [
  //         BoxShadow(
  //           blurRadius: 10,
  //           color: Colors.black12,
  //         ),
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Text(
  //           value,
  //           style: const TextStyle(
  //             fontSize: 20, // 👈 stats number size
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Text(
  //           label,
  //           style: const TextStyle(
  //             fontSize: 12, // 👈 stats label size
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  static Widget _statCard(
  String imagePath,   // 👈 NEW
  String value,
  String label,
) {
  return Container(
    padding: const EdgeInsets.all(12),
    width: 160,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(
          blurRadius: 10,
          color: Colors.black12,
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    ),
  );
}


  // ===================== SETTINGS TILE =====================
  static Widget _tile(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 32, // 👈 leading icon size
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 24, // 👈 list tile text size
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 20, // 👈 arrow icon size
      ),
      onTap: onTap,
    );
  }
}
