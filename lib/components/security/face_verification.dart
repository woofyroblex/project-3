// face_verification.dart
import 'package:flutter/material.dart';

class FaceVerificationScreen extends StatefulWidget {
  final Function(bool) onVerificationComplete;

  const FaceVerificationScreen({Key? key, required this.onVerificationComplete})
      : super(key: key);

  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  bool _isVerifying = false;

  void _startFaceVerification() async {
    setState(() {
      _isVerifying = true;
    });

    // Simulate face verification process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isVerifying = false;
    });

    widget.onVerificationComplete(true);
  }

  @override
  void initState() {
    super.initState();
    _startFaceVerification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Verification')),
      body: Center(
        child: _isVerifying
            ? const CircularProgressIndicator()
            : const Text('Face Verification Completed'),
      ),
    );
  }
}
