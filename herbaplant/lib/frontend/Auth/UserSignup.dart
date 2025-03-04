import 'package:flutter/material.dart';
import '/services/api_service.dart';

class UserSignup extends StatefulWidget {
  const UserSignup({super.key});

  @override
  _UserSignupState createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;

  // Function to Handle Registration
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      _showSnackbar(
          "Please complete the form properly", Colors.red, Icons.warning);
      return;
    }

    setState(() => _isLoading = true);

    String? response = await ApiService.registerUser(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (response != null) {
      if (response.toLowerCase().contains("successful")) {
        _showSnackbar("Registration Successful! Check your email to verify.",
            Colors.green, Icons.check_circle);
        Navigator.pop(context); // Redirect back to login after success
      } else {
        _showSnackbar(response, Colors.red, Icons.error);
      }
    } else {
      _showSnackbar("Registration failed!", Colors.red, Icons.error);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Verify Your Email"),
        content: const Text(
            "A verification email has been sent. Please check your inbox."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Snackbar Helper
  void _showSnackbar(String message, Color bgColor, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
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
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                // Logo Section
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Image.asset(
                    'assets/image/logo-new.png',
                    height: 80,
                  ),
                ),
                const SizedBox(height: 30),

                // Sign Up Form
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.green),
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.green),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.green),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon:
                              const Icon(Icons.lock, color: Colors.green),
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Terms and Conditions Checkbox with Clickable Text
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: _showTermsAndConditions,
                              child: const Text(
                                'I agree to the Terms and Conditions',
                                style: TextStyle(
                                  color: Colors.blue,
                                  
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Create Account Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Create Account',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),

                      // Login Button
                      OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Already have an account? Login',
                            style:
                                TextStyle(fontSize: 16, color: Colors.green)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to Show Terms and Conditions Dialog
  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Terms and Conditions"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "By creating an account and using this application, you agree to the following terms and conditions:\n",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "1. Acceptance of Terms\n"
                "   By signing up, you acknowledge that you have read, understood, and agreed to comply with these Terms and Conditions.\n\n"
                "2. User Responsibilities\n"
                "   - You must provide accurate and complete information during registration.\n"
                "   - You are responsible for maintaining the confidentiality of your account credentials.\n"
                "   - Any unauthorized activity on your account is your responsibility, and you must notify us immediately if you suspect a security breach.\n\n"
                "3. Data Privacy and Security\n"
                "   - We collect and process your personal data in accordance with our **Privacy Policy**.\n"
                "   - Your data will be securely stored and will not be shared with third parties without your consent, except as required by law.\n"
                "   - You have the right to request access, correction, or deletion of your personal data.\n\n"
                "4. Prohibited Activities\n"
                "   You agree not to:\n"
                "   - Use the app for any unlawful purposes.\n"
                "   - Attempt to hack, modify, or distribute unauthorized copies of the app.\n"
                "   - Violate the rights of other users, including harassment or fraudulent activity.\n\n"
                "5. Service Modifications & Termination\n"
                "   - We reserve the right to modify, suspend, or terminate the app or your access at any time, with or without notice.\n"
                "   - Continued use of the app after changes to these terms constitutes your acceptance of the updated terms.\n\n"
                "6. Limitation of Liability\n"
                "   - We are not liable for any indirect, incidental, or consequential damages arising from your use of the app.\n"
                "   - We do not guarantee uninterrupted or error-free service.\n\n"
                "7. Governing Law\n"
                "   These terms shall be governed by and interpreted in accordance with the applicable laws of your jurisdiction.\n\n"
                "By clicking 'Agree', you confirm that you have read and accepted these Terms and Conditions.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _acceptTerms = true; // Auto-check the checkbox
              });
              Navigator.pop(context);
            },
            child: const Text("Agree"),
          ),
        ],
      ),
    );
  }
}
