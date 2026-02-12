import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientPrescriptions extends StatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  State<PatientPrescriptions> createState() =>
      _PatientPrescriptionsState();
}

class _PatientPrescriptionsState
    extends State<PatientPrescriptions> {

  final GlobalKey _globalKey = GlobalKey();

  Future<void> _saveImage() async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = Directory('/storage/emulated/0/Download');

      final file = File(
        '${directory.path}/prescription_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved to Downloads")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescription"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: patientId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {

          // 🔴 Handle error properly
          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No prescription found"),
            );
          }

          final doc = snapshot.data!.docs.first;
          final data = doc.data() as Map<String, dynamic>;

          final doctor =
              data.containsKey('doctorEmail') ? data['doctorEmail'] : '';

          final patient =
              data.containsKey('patientName') ? data['patientName'] : '';

          final disease =
              data.containsKey('disease') ? data['disease'] : '';

          final medicines =
              data.containsKey('medicines') ? data['medicines'] : '';

          final dosage =
              data.containsKey('dosage') ? data['dosage'] : '';

          final fee =
              data.containsKey('fee') ? data['fee'] : '';

          String formattedDate = '';

          if (data.containsKey('createdAt')) {
            Timestamp ts = data['createdAt'];
            DateTime dt = ts.toDate();
            formattedDate =
                "${dt.day}/${dt.month}/${dt.year}";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [

                        const Center(
                          child: Text(
                            "Medical Prescription",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const Divider(height: 30),

                        Text("Doctor: $doctor"),
                        Text("Patient: $patient"),
                        Text("Date: $formattedDate"),

                        const SizedBox(height: 15),

                        Text("Disease: $disease"),

                        const SizedBox(height: 15),

                        Text("Medicines: $medicines"),

                        const SizedBox(height: 15),

                        Text("Dosage: $dosage"),

                        const SizedBox(height: 15),

                        Text(
                          "Fee: ₹$fee",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _saveImage,
                    icon: const Icon(Icons.download),
                    label: const Text("Save to Downloads"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
