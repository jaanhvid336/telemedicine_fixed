import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';

class BookAppointment extends StatefulWidget {
  const BookAppointment({super.key});

  @override
  State<BookAppointment> createState() => _BookAppointmentState();
}

class _BookAppointmentState extends State<BookAppointment> {
  String? doctorId;
  String? doctorName;
  String? selectedDate;
  String? selectedTime;
  String patientName = '';

  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _loadPatientName();
  }

  Future<void> _loadPatientName() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        patientName = doc.data()?['name'] ?? 'Patient';
      });
    }
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      selectedDate = "${date.day}-${date.month}-${date.year}";
      selectedTime = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
    });
  }

  Future<void> confirmAppointment() async {
    if (doctorId == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select all fields")));
      return;
    }

    await FirebaseFirestore.instance.collection('appointments').add({
      'patientId': user.uid,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': selectedDate,
      'time': selectedTime,
      'status': 'upcoming',
      'createdAt': Timestamp.now(),
    });

    setState(() {
      selectedDate = null;
      selectedTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Appointment booked successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Appointment"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// ---------------- SELECT DOCTOR ----------------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctor_profile')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                return DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Select Doctor",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    final name = data['doctorName'] ?? data['name'] ?? 'Doctor';
                    final speciality = data['speciality'];

                    final displayText =
                        (speciality != null && speciality.toString().isNotEmpty)
                        ? "$name (${speciality})"
                        : name;

                    return DropdownMenuItem<String>(
                      value: data['uid'],
                      child: Text(displayText),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final doc = snapshot.data!.docs.firstWhere(
                      (d) => (d.data() as Map<String, dynamic>)['uid'] == value,
                    );

                    final data = doc.data() as Map<String, dynamic>;

                    setState(() {
                      doctorId = data['uid'];
                      doctorName =
                          data['doctorName'] ?? data['name'] ?? 'Doctor';
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            /// SELECT DATE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month, color: Colors.black),
                label: const Text(
                  "Select Date & Time",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 239, 253, 160),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: pickDateTime,
              ),
            ),

            const SizedBox(height: 20),

            /// CONFIRM BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: Colors.black),
                label: const Text(
                  "Confirm Appointment",
                  style: TextStyle(color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: confirmAppointment,
              ),
            ),

            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Appointments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            /// ---------------- MY APPOINTMENTS ----------------
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Text("No appointments yet");
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
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
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['doctorName'] ?? 'Doctor',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text("${data['date']} • ${data['time']}"),
                            const SizedBox(height: 6),
                            Text(
                              "Status: $status",
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// CHAT + DELETE ROW
                            Row(
                              children: [
                                if (status == 'accepted' ||
                                    status == 'completed')
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.chat),
                                      label: const Text("Chat"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          245,
                                          246,
                                          246,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ChatPage(
                                              appointmentId: doc.id,
                                              otherUserName:
                                                  data['doctorName'] ??
                                                  'Doctor',
                                              isAccepted: true,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                if (status == 'accepted')
                                  const SizedBox(width: 10),

                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () => doc.reference.delete(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
