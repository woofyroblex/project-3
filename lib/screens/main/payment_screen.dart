import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class PaymentScreen extends StatefulWidget {
  final String videoUrl; // URL of the verification video
  final double amount;
  final String contactInfo;

  PaymentScreen({
    required this.videoUrl,
    required this.amount,
    required this.contactInfo,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isVideoVerified = false;

  @override
  void initState() {
    super.initState();
    _videoController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoController,
                autoPlay: false,
                looping: false,
              );
            });
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _verifyVideo() {
    if (_videoController.value.position == _videoController.value.duration) {
      setState(() {
        _isVideoVerified = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video Verified Successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please watch the full video to verify.')),
      );
    }
  }

  void _processPayment() {
    if (_isVideoVerified) {
      // Proceed with payment logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment of ₹${widget.amount} Successful!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please verify the video first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Video Verification:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: Chewie(controller: _chewieController!),
                  )
                : Center(child: CircularProgressIndicator()),
            ElevatedButton(
              onPressed: () {
                _videoController.play();
              },
              child: Text('Play Video'),
            ),
            ElevatedButton(
              onPressed: _verifyVideo,
              child: Text('Verify Video'),
            ),
            SizedBox(height: 20),
            if (_isVideoVerified)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Info:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.contactInfo),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _processPayment,
                    child: Text('Pay ₹${widget.amount}'),
                  ),
                ],
              )
            else
              Text('Please verify the video to view contact information.',
                  style:
                      TextStyle(color: const Color.fromARGB(255, 240, 72, 60))),
          ],
        ),
      ),
    );
  }
}
