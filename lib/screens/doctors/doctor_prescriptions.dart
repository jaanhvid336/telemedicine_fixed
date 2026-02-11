import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPrescriptionsPage extends StatefulWidget {
  const DoctorPrescriptionsPage({super.key});

  @override
  State<DoctorPrescriptionsPage> createState() =>
      _DoctorPrescriptionsPageState();
}

class _DoctorPrescriptionsPageState extends State<DoctorPrescriptionsPage> {
  String? selectedAppointmentId;
  String? selectedPatientId;
  String? selectedPatientName;

  final diseaseController = TextEditingController();
  final medicineController = TextEditingController();
  final dosageController = TextEditingController();
  final feeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final doctorId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Prescription"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 SELECT PATIENT (ACCEPTED APPOINTMENTS)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: doctorId)
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No accepted patients found");
                }

                return DropdownButtonFormField<String>(
                  value: selectedAppointmentId,
                  decoration: const InputDecoration(
                    labelText: "Select Patient",
                    border: OutlineInputBorder(),
                  ),
                  items: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: doc.id, // 🔥 use appointmentId
                      child: Text(data['patientName'] ?? "Patient"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final doc = snapshot.data!.docs.firstWhere(
                      (d) => d.id == value,
                    );

                    final data = doc.data() as Map<String, dynamic>;

                    setState(() {
                      selectedAppointmentId = doc.id;
                      selectedPatientId = data['patientId'];
                      selectedPatientName = data['patientName'];
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: diseaseController,
              decoration: const InputDecoration(
                labelText: "Disease / Diagnosis",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: medicineController,
              decoration: const InputDecoration(
                labelText: "Medicines",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: "Dosage",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Consultation Fee",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (selectedAppointmentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Select patient first")),
                    );
                    return;
                  }

                  /// 🔥 UPDATE APPOINTMENT (IMPORTANT)
                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .doc(selectedAppointmentId)
                      .update({
                        'diagnosis': diseaseController.text,
                        'prescription': medicineController.text,
                        'dosage': dosageController.text,
                        'fee': feeController.text,
                        'status': 'completed', // 🔥 THIS FIXES HISTORY
                        'completedAt': Timestamp.now(),
                      });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Prescription Saved & Appointment Completed",
                      ),
                    ),
                  );

                  diseaseController.clear();
                  medicineController.clear();
                  dosageController.clear();
                  feeController.clear();

                  setState(() {
                    selectedAppointmentId = null;
                  });
                },
                child: const Text("Save Prescription"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
