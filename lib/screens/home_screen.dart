import 'package:flutter/material.dart';
import 'doctors/doctor_home.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  const HomeScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    // 🔁 Redirect doctor AFTER first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (role == "Doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DoctorHome()),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 143, 194, 245),

      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 23, 1, 74),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "$role Dashboard",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),

      // ✅ Only patient UI stays here
      body: patientView(),
    );
  }

  // ================= PATIENT VIEW =================
  Widget patientView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          welcomeCard(
            title: "Welcome, Patient 👋",
            subtitle: "Track your health & appointments",
            icon: Icons.favorite,
          ),
          const SizedBox(height: 20),

          dashboardCard(
            icon: Icons.receipt_long,
            title: "My Prescriptions",
            subtitle: "View past & active prescriptions",
          ),
          dashboardCard(
            icon: Icons.history,
            title: "Medical History",
            subtitle: "Reports & consultation history",
          ),
          dashboardCard(
            icon: Icons.calendar_today,
            title: "My Appointments",
            subtitle: "Upcoming & previous visits",
          ),
          dashboardCard(
            icon: Icons.person_outline,
            title: "My Profile",
            subtitle: "Personal & medical details",
          ),
        ],
      ),
    );
  }

  // ================= WELCOME CARD =================
  Widget welcomeCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 23, 0, 55),
            Color.fromARGB(255, 26, 6, 106),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(icon, size: 30, color: Color(0xFF1565C0)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= DASHBOARD CARD =================
  Widget dashboardCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: const Color.fromARGB(255, 170, 211, 241),
          child: Icon(icon, color: const Color(0xFF1565C0)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: add navigation later
        },
      ),
    );
  }
}
