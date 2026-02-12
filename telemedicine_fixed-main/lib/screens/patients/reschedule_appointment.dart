import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RescheduleAppointmentPage extends StatefulWidget {
  final String appointmentId;
  final String doctorId;

  const RescheduleAppointmentPage({
    super.key,
    required this.appointmentId,
    required this.doctorId,
  });

  @override
  State<RescheduleAppointmentPage> createState() =>
      _RescheduleAppointmentPageState();
}

class _RescheduleAppointmentPageState extends State<RescheduleAppointmentPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String patientName = "Patient";
  Map<String, dynamic> doctorData = {
    'name': 'Doctor',
    'speciality': 'Not available',
  };

  @override
  void initState() {
    super.initState();
    fetchPatientName();
    fetchDoctorData();
  }

  Future<void> fetchPatientName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      setState(() {
        patientName = doc.data()?['name'] ?? "Patient";
      });
    }
  }

  Future<void> fetchDoctorData() async {
    if (widget.doctorId.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .get();

    if (doc.exists) {
      setState(() {
        doctorData = doc.data()!;
      });
    }
  }

  Future<void> saveChanges() async {
    if (selectedDate == null || selectedTime == null) return;

    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(widget.appointmentId)
        .update({
          'date':
              "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
          'time': selectedTime!.format(context),
        });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reschedule Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hello, $patientName 👋",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Doctor: ${doctorData['name']}"),
            Text("Speciality: ${doctorData['speciality']}"),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  initialDate: DateTime.now(),
                );
                setState(() {});
              },
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : selectedDate.toString().split(" ")[0],
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                setState(() {});
              },
              child: Text(
                selectedTime == null
                    ? "Select Time"
                    : selectedTime!.format(context),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveChanges,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
