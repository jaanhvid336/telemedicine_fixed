import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../patients/chat.dart';

class MyPatientsPage extends StatelessWidget {
  const MyPatientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('doctorId', isEqualTo: doctorId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No patients yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final appointmentDoc = snapshot.data!.docs[index];
              final appointmentData =
                  appointmentDoc.data() as Map<String, dynamic>;

              final patientId = appointmentData['patientId'];
              final status = appointmentData['status'] ?? 'upcoming';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(patientId)
                    .get(),
                builder: (context, userSnapshot) {
                  String patientName =
                      appointmentData['patientName'] ?? "Patient";

                  if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    final userData =
                        userSnapshot.data!.data() as Map<String, dynamic>;
                    patientName = userData['name'] ?? patientName;
                  }

                  Color statusColor;
                  switch (status) {
                    case 'accepted':
                      statusColor = Colors.green;
                      break;
                    case 'rejected':
                      statusColor = Colors.red;
                      break;
                    case 'postponed':
                      statusColor = Colors.orange;
                      break;
                    default:
                      statusColor = Colors.blue;
                  }

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Patient Name
                          Text(
                            patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${appointmentData['date']} • ${appointmentData['time']}",
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Status: $status",
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// UPCOMING → Accept / Reject / Postpone
                          if (status == 'upcoming') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    onPressed: () {
                                      appointmentDoc.reference.update({
                                        'status': 'accepted',
                                      });
                                    },
                                    child: const Text("Accept"),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () {
                                      appointmentDoc.reference.update({
                                        'status': 'rejected',
                                      });
                                    },
                                    child: const Text("Reject"),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  appointmentDoc.reference.update({
                                    'status': 'postponed',
                                  });
                                },
                                child: const Text("Postpone"),
                              ),
                            ),
                          ],

                          /// ACCEPTED → Show Chat Button
                          if (status == 'accepted' || status == 'completed')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        appointmentId: appointmentDoc.id,
                                        otherUserName: patientName,
                                        isAccepted: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
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
