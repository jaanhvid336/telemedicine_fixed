import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../screens/login_screen.dart';
import '../screens/patients/patient_home.dart';
import '../screens/doctors/doctor_home.dart';

class RoleRedirect extends StatefulWidget {
  const RoleRedirect({super.key});

  @override
  State<RoleRedirect> createState() => _RoleRedirectState();
}

class _RoleRedirectState extends State<RoleRedirect> {
  @override
  void initState() {
    super.initState();
    _redirectUser();
  }

  Future<void> _redirectUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // 🔴 NOT LOGGED IN
      if (user == null) {
        _go(const LoginScreen());
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // 🔴 USER DOCUMENT NOT FOUND
      if (!doc.exists) {
        _go(const LoginScreen());
        return;
      }

      final data = doc.data();
      final role = data?['role'];

      // 🔴 ROLE MISSING
      if (role == null) {
        _go(const LoginScreen());
        return;
      }

      // ✅ ROLE BASED REDIRECT
      if (role == 'patient') {
        _go(const PatientHome());
      } else if (role == 'doctor') {
        _go(const DoctorHome());
      } else {
        _go(const LoginScreen());
      }
    } catch (e) {
      // 🔴 ANY ERROR → SAFE EXIT
      _go(const LoginScreen());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
