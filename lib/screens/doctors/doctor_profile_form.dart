import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileForm extends StatefulWidget {
  const DoctorProfileForm({super.key});

  @override
  State<DoctorProfileForm> createState() => _DoctorProfileFormState();
}

class _DoctorProfileFormState extends State<DoctorProfileForm> {
  final phoneController = TextEditingController();
  final degreeController = TextEditingController();
  final experienceController = TextEditingController();
  final specialityController = TextEditingController();

  String doctorName = '';

  @override
  void initState() {
    super.initState();
    _loadDoctorName();
    _loadProfile();
  }

  Future<void> _loadDoctorName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (userDoc.exists) {
      doctorName = userDoc['name'] ?? '';
    }
  }

  Future<void> _loadProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('doctor_profile')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      phoneController.text = data['phone'] ?? '';
      degreeController.text = data['degree'] ?? '';
      experienceController.text = data['experience'] ?? '';
      specialityController.text = data['speciality'] ?? '';
    }
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('doctor_profile').doc(uid).set({
      'uid': uid,
      'name': doctorName,
      'phone': phoneController.text.trim(),
      'degree': degreeController.text.trim(),
      'experience': experienceController.text.trim(),
      'speciality': specialityController.text.trim(),
      'createdAt': Timestamp.now(),
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile saved')));

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: saveProfile),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: degreeController,
              decoration: const InputDecoration(labelText: 'Degree'),
            ),
            TextField(
              controller: experienceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Experience (years)',
              ),
            ),
            TextField(
              controller: specialityController,
              decoration: const InputDecoration(labelText: 'Speciality'),
            ),
          ],
        ),
      ),
    );
  }
}
