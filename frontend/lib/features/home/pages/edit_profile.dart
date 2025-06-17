import 'package:flutter/material.dart';


class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/hamid.jpg'),
            ),
            const SizedBox(height: 16),
            buildTextField(Icons.person, "Enter your name"),
            buildTextField(Icons.email, "Enter your email address"),
            buildTextField(Icons.lock, "Enter your password"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Save logic
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF50C2C9),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xFF50C2C9)),
            hintText: hint,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
