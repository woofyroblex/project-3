import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../state/user_provider.dart';

class SecurityVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const SecurityVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<SecurityVerificationScreen> createState() =>
      _SecurityVerificationScreenState();
}

class _SecurityVerificationScreenState
    extends State<SecurityVerificationScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String _verificationCode = '';
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter verification code sent to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                hintText: '6-digit code',
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (value) {
                setState(() => _verificationCode = value);
                if (value.length == 6) {
                  _verifyCode();
                }
              },
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text('Verify'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (_verificationCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter complete verification code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isVerified = await _authService.verifyPhoneCode(
        phoneNumber: widget.phoneNumber,
        code: _verificationCode,
      );

      if (isVerified) {
        await Provider.of<UserProvider>(context, listen: false)
            .refreshUserData();
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
