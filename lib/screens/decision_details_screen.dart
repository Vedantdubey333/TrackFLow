import 'package:flutter/material.dart';

class DecisionDetailsScreen extends StatefulWidget {
  const DecisionDetailsScreen({super.key});

  @override
  State<DecisionDetailsScreen> createState() => _DecisionDetailsScreenState();
}

class _DecisionDetailsScreenState extends State<DecisionDetailsScreen> {
  int _currentIndex = 0;

  String selectedCategory = "Tech";
  DateTime? decisionDate;
  DateTime? reviewDate;
  bool affectsUserData = false;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController timePressureController = TextEditingController();
  final TextEditingController stakeholdersController = TextEditingController();
  final TextEditingController expectationController = TextEditingController();

  // ================= FONT SIZES (EDIT HERE) =================
  static const double appBarTitleSize = 20;
  static const double pageTitleSize = 30;
  static const double fieldLabelSize = 26;
  static const double fieldTextSize = 18;
  static const double buttonTextSize = 20;
  static const double switchTextSize = 24;
  // static const double bottomNavLabelSize = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text(
          "Add New Decision",
          style: TextStyle(
            fontSize: appBarTitleSize + 4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔹 PAGE TITLE
            const Text(
              "Decision Details",
              style: TextStyle(
                fontSize: pageTitleSize + 2,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _inputField(
              label: "Decision Title",
              controller: titleController,
              hint: "Enter decision title",
            ),

            const SizedBox(height: 14),

            // 🔹 CATEGORY
            const Text(
              "Category",
              style: TextStyle(
                fontSize: fieldLabelSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: _inputDecoration(hint: "Select category"),
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: fieldTextSize),
              items: ["Tech", "Product", "HR", "Personal"]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(fontSize: fieldTextSize,color: Colors.black),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedCategory = value!);
              },
            ),

            const SizedBox(height: 14),

            _datePicker(
              label: "Decision Date",
              date: decisionDate,
              textSize: fieldTextSize,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (picked != null) setState(() => decisionDate = picked);
              },
            ),

            const SizedBox(height: 14),

            _inputField(
              label: "Time Pressure",
              controller: timePressureController,
              hint: "Low / Medium / High",
            ),

            const SizedBox(height: 14),

            _inputField(
              label: "Stakeholders Involved",
              controller: stakeholdersController,
              hint: "Names / Teams",
            ),

            const SizedBox(height: 14),

            _inputField(
              label: "What do you expect?",
              controller: expectationController,
              hint: "Expected outcome",
              maxLines: 3,
            ),

            const SizedBox(height: 14),

            // 🔹 SWITCH
            SwitchListTile(
              value: affectsUserData,
              onChanged: (val) => setState(() => affectsUserData = val),
              title: const Text(
                "Does this decision impact stored user data?",
                style: TextStyle(fontSize: switchTextSize),
              ),
            ),

            const SizedBox(height: 14),

            _datePicker(
              label: "Review Date",
              date: reviewDate,
              textSize: fieldTextSize,
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (picked != null) setState(() => reviewDate = picked);
              },
            ),

            const SizedBox(height: 24),

            // 🔹 NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: buttonTextSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ================= INPUT FIELD =================
  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: fieldLabelSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: fieldTextSize),
          decoration: _inputDecoration(hint: hint),
        ),
      ],
    );
  }

  // ================= DATE PICKER =================
  Widget _datePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required double textSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: fieldLabelSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: _boxDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? "Select date"
                      : "${date.day}/${date.month}/${date.year}",
                  style: TextStyle(fontSize: textSize),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= INPUT DECORATION =================
  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: fieldTextSize),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // ================= BOX DECORATION =================
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  // ================= BOTTOM NAV =================
  // Widget _buildBottomNavBar() {
  //   return BottomNavigationBar(
  //     currentIndex: _currentIndex,
  //     selectedFontSize: bottomNavLabelSize,
  //     unselectedFontSize: bottomNavLabelSize,
  //     onTap: (i) => setState(() => _currentIndex = i),
  //     type: BottomNavigationBarType.fixed,
  //     items: const [
  //       BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //       BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Decisions"),
  //       BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Analytics"),
  //       BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
  //     ],
  //   );
  // }

   // ================= BOTTOM NAV BAR =================
  Widget _buildBottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          _navItem(Icons.home, "Home", 0),
          _navItem(Icons.assignment, "Decisions", 1),
          _navItem(Icons.bar_chart, "Analytics", 2),
          _navItem(Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  // ================= NAV ITEM WITH GLOW =================
  BottomNavigationBarItem _navItem(
      IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        size: 26,
        color: isActive ? Colors.blue : Colors.grey,
        shadows: isActive
            ? [
                Shadow(
                  blurRadius: 12,
                  color: Colors.blue.withOpacity(0.6),
                )
              ]
            : [],
      ),
      label: label,
    );
  }
}
