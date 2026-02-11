import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all doctors for patient screen
  Future<List<Map<String, dynamic>>> fetchDoctors() async {
    QuerySnapshot doctorProfiles = await _firestore
        .collection('doctor_profiles')
        .get();

    List<Map<String, dynamic>> doctors = [];

    for (var doc in doctorProfiles.docs) {
      String uid = doc.id;

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        doctors.add({
          'name': userDoc['name'],
          'speciality': doc['speciality'],
          'experience': doc['experience'],
          'phoneNo': doc['phoneNo'],
        });
      }
    }

    return doctors;
  }
}
