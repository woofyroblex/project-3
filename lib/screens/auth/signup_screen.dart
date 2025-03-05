//lib/screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import '../../components/auth/auth_button.dart';
import '../../components/auth/auth_text_field.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool success = await AuthService().signup(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (success) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showError('Signup failed. Please try again.');
        }
      } catch (e) {
        _showError('An error occurred: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AuthTextField(
                controller: _nameController,
                labelText: 'Name',
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) =>
                    value!.isEmpty ? 'Enter a valid email' : null,
              ),
              SizedBox(height: 16),
              AuthTextField(
                controller: _passwordController,
                labelText: 'Password',
                obscureText: true,
                validator: (value) =>
                    value!.length < 6 ? 'Password too short' : null,
              ),
              SizedBox(height: 32),
              _isLoading
                  ? CircularProgressIndicator()
                  : AuthButton(
                      text: 'Sign Up',
                      onPressed: _signup,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
