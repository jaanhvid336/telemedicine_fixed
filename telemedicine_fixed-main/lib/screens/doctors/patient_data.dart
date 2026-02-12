import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorHistoryPage extends StatelessWidget {
  const DoctorHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient History"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed patients"));
          }

          final completedAppointments = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: completedAppointments.length,
            itemBuilder: (context, index) {
              final data =
                  completedAppointments[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Patient Name
                      Text(
                        data['patientName'] ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// Diagnosis
                      Text("Diagnosis: ${data['diagnosis'] ?? 'N/A'}"),

                      const SizedBox(height: 6),

                      /// Fee
                      Text("Consultation Fee: ₹${data['fee'] ?? '0'}"),

                      const SizedBox(height: 6),

                      /// Date & Time
                      Text("${data['date']} • ${data['time']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
