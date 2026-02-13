import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientPrescriptions extends StatefulWidget {
  const PatientPrescriptions({super.key});

  @override
  State<PatientPrescriptions> createState() => _PatientPrescriptionsState();
}

class _PatientPrescriptionsState extends State<PatientPrescriptions> {
  Future<void> _saveImage(GlobalKey key) async {
    try {
      RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3);

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final blob = html.Blob([pngBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);

      html.AnchorElement(href: url)
        ..setAttribute(
          "download",
          "prescription_${DateTime.now().millisecondsSinceEpoch}.png",
        )
        ..click();

      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Downloaded successfully")),
      );
    } catch (e) {
      print("Save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Prescriptions"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prescriptions')
            .where('patientId', isEqualTo: patientId)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No prescriptions found"));
          }

          final prescriptions = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prescriptions.length,
            itemBuilder: (context, index) {
              final doc = prescriptions[index];
              final data = doc.data() as Map<String, dynamic>;
              final key = GlobalKey();

              return Column(
                children: [
                  RepaintBoundary(
                    key: key,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 15),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text("Doctor: ${data['doctorName'] ?? 'Unknown'}"),
                          Text("Patient: ${data['patientName'] ?? ''}"),
                          const SizedBox(height: 15),
                          Text("Disease: ${data['disease'] ?? ''}"),
                          const SizedBox(height: 15),
                          Text("Medicines: ${data['medicines'] ?? ''}"),
                          const SizedBox(height: 15),
                          Text("Dosage: ${data['dosage'] ?? ''}"),
                          const SizedBox(height: 15),
                          Text("Fee: ₹${data['fee'] ?? ''}"),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _saveImage(key),
                      icon: const Icon(Icons.download),
                      label: const Text("Download Prescription"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
