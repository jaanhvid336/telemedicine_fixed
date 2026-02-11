import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientHistoryPage extends StatelessWidget {
  const PatientHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("History"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: patientId)
            .where('status', isEqualTo: 'completed')
            .snapshots(),
        builder: (context, appointmentSnapshot) {
          if (appointmentSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!appointmentSnapshot.hasData ||
              appointmentSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No completed history"));
          }

          final appointments = appointmentSnapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointmentData =
                  appointments[index].data() as Map<String, dynamic>;

              final doctorId = appointmentData['doctorId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('doctor_profile')
                    .doc(doctorId)
                    .get(),
                builder: (context, doctorSnapshot) {
                  if (doctorSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final doctorData =
                      doctorSnapshot.data?.data() as Map<String, dynamic>?;

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
                          /// Doctor Name
                          Text(
                            appointmentData['doctorName'] ?? 'Doctor',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          /// Degree
                          Text("Degree: ${doctorData?['degree'] ?? 'N/A'}"),

                          /// Phone
                          Text("Contact: ${doctorData?['phone'] ?? 'N/A'}"),

                          const Divider(height: 20),

                          /// Diagnosis
                          Text(
                            "Diagnosis: ${appointmentData['diagnosis'] ?? 'N/A'}",
                          ),

                          /// Prescription
                          Text(
                            "Prescription: ${appointmentData['prescription'] ?? 'N/A'}",
                          ),

                          const SizedBox(height: 6),

                          /// Date & Time
                          Text(
                            "${appointmentData['date']} • ${appointmentData['time']}",
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
