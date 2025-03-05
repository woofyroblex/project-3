// video_verification.dart
import 'package:flutter/material.dart';

class VideoVerificationScreen extends StatefulWidget {
  final Function(bool) onVerificationComplete;
  final String videoUrl;

  const VideoVerificationScreen(
      {Key? key, required this.onVerificationComplete, required this.videoUrl})
      : super(key: key);

  @override
  _VideoVerificationScreenState createState() =>
      _VideoVerificationScreenState();
}

class _VideoVerificationScreenState extends State<VideoVerificationScreen> {
  bool _isVerifying = false;

  void _verifyVideo() async {
    setState(() {
      _isVerifying = true;
    });

    // Simulate video verification process
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isVerifying = false;
    });

    widget.onVerificationComplete(true);
  }

  @override
  void initState() {
    super.initState();
    _verifyVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Verification')),
      body: Center(
        child: _isVerifying
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Video Verification Completed'),
                  ElevatedButton(
                    onPressed: () => widget.onVerificationComplete(true),
                    child: const Text('Proceed'),
                  ),
                ],
              ),
      ),
    );
  }
}
