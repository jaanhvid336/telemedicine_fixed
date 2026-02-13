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
    final doctor = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Prescription"),
        backgroundColor: Colors.blue,
      ),

      /// ✅ FIXED OVERFLOW WITH SCROLL
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ================= SELECT ACCEPTED PATIENT =================
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('doctorId', isEqualTo: doctor!.uid)
                  .where('status', isEqualTo: 'accepted')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

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
                      value: doc.id,
                      child: Text(data['patientName']),
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

                  if (diseaseController.text.isEmpty ||
                      medicineController.text.isEmpty ||
                      dosageController.text.isEmpty ||
                      feeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Fill all fields")),
                    );
                    return;
                  }

                  try {
                    /// 🔥 FETCH DOCTOR NAME
                    final doctorProfile = await FirebaseFirestore.instance
                        .collection('doctor_profile')
                        .where('uid', isEqualTo: doctor.uid)
                        .limit(1)
                        .get();

                    String doctorName = "Doctor";

                    if (doctorProfile.docs.isNotEmpty) {
                      doctorName = doctorProfile.docs.first['name'];
                    }

                    /// SAVE PRESCRIPTION
                    await FirebaseFirestore.instance
                        .collection('prescriptions')
                        .add({
                      'doctorId': doctor.uid,
                      'doctorName': doctorName,
                      'doctorEmail': doctor.email,
                      'patientId': selectedPatientId,
                      'patientName': selectedPatientName,
                      'disease': diseaseController.text.trim(),
                      'medicines': medicineController.text.trim(),
                      'dosage': dosageController.text.trim(),
                      'fee': int.parse(feeController.text),
                      'createdAt': Timestamp.now(),
                    });

                    /// UPDATE APPOINTMENT STATUS
                    await FirebaseFirestore.instance
                        .collection('appointments')
                        .doc(selectedAppointmentId)
                        .update({
                      'status': 'completed',
                      'completedAt': Timestamp.now(),
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Prescription Saved Successfully"),
                      ),
                    );

                    diseaseController.clear();
                    medicineController.clear();
                    dosageController.clear();
                    feeController.clear();

                    setState(() {
                      selectedAppointmentId = null;
                      selectedPatientId = null;
                      selectedPatientName = null;
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
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
