import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'book_appointment.dart';
import 'patient_prescriptions.dart';
import 'patient_history.dart';

class PatientHome extends StatefulWidget {
  const PatientHome({super.key});

  @override
  State<PatientHome> createState() => _PatientHomeState();
}

class _PatientHomeState extends State<PatientHome> {
  int _index = 0;
  String patientName = '';

  final List<Widget> pages = const [
    BookAppointment(),
    PatientPrescriptions(),
    PatientHistoryPage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        patientName = doc.data()?['name'] ?? 'Patient';
      });
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(patientName, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Appointments",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Prescriptions",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
        ],
      ),
    );
  }
}
