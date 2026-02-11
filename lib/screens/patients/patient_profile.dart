import 'package:flutter/material.dart';

class PatientProfilePage extends StatelessWidget {
  const PatientProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            SizedBox(height: 12),
            Text("John Doe", style: TextStyle(fontSize: 18)),
            Text("john@example.com"),
          ],
        ),
      ),
    );
  }
}
