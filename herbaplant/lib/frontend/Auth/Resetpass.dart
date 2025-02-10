import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

void _handleResetPassword() async {
  final newPassword = _newPasswordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (newPassword.isEmpty || confirmPassword.isEmpty) {
    _showSnackbar("All fields are required!", Colors.red, Icons.warning);
    return;
  }
  if (newPassword.length < 6) {
    _showSnackbar("Password must be at least 6 characters!", Colors.red, Icons.warning);
    return;
  }
  if (newPassword != confirmPassword) {
    _showSnackbar("Passwords do not match!", Colors.red, Icons.warning);
    return;
  }

  setState(() => _isLoading = true);
  String response = await ApiService.resetPassword(widget.token, newPassword);
  setState(() => _isLoading = false);

  if (response.toLowerCase().contains("successful")) {
    GoRouter.of(context).go('/login');
  } else {
    _showSnackbar("Error: $response", Colors.red, Icons.error);
  }
}


  void _showSnackbar(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Confirm Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              child: _isLoading ? const CircularProgressIndicator() : const Text("Reset Password"),
            ),
          ],
        ),
      ),
    );
  }
}
