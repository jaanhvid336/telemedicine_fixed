import 'package:flutter/material.dart';

class VideoCallPage extends StatelessWidget {
  final String phoneNo;

  const VideoCallPage({super.key, required this.phoneNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Call")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Doctor Contact Number"),
            const SizedBox(height: 10),
            Text(
              phoneNo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
