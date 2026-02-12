import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class PatientAppointments extends StatelessWidget {
  const PatientAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    final patientUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Appointments"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .where('patientId', isEqualTo: patientUid)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No appointments found",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final status = data['status'] ?? 'upcoming';

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
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Name
                      Text(
                        data['doctorName'] ?? 'Doctor',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Date & Time
                      Text("${data['date']}  •  ${data['time']}"),

                      const SizedBox(height: 8),

                      // Status
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // CHAT BUTTON (only if accepted)
                          if (status == 'accepted')
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                icon: const Icon(Icons.chat),
                                label: const Text("Chat"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatPage(
                                        appointmentId: doc.id,
                                        otherUserName:
                                            data['doctorName'] ?? 'Doctor',
                                        isAccepted:
                                            data['status'] == 'accepted',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                          if (status == 'accepted') const SizedBox(width: 10),

                          // DELETE BUTTON
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              label: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                await doc.reference.delete();
                              },
                            ),
                          ),
                        ],
                      ),
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
