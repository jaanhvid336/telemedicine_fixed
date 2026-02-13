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
        title: const Text("Doctor History"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('doctorId', isEqualTo: doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No history found"));
          }

          final prescriptions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final data = prescriptions[index].data() as Map<String, dynamic>;

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
                      Text(
                        data['patientName'] ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Text("Diagnosis: ${data['disease'] ?? 'N/A'}"),
                      Text("Medicines: ${data['medicines'] ?? 'N/A'}"),
                      Text("Dosage: ${data['dosage'] ?? 'N/A'}"),
                      Text("Consultation Fee: ₹${data['fee'] ?? 0}"),
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
