import 'package:flutter/material.dart';
import '../user/Screen/main_navigation.dart'; // Import MainNavigation screen
import 'UserSignup.dart'; // Import UserSignup screen

class UserSignin extends StatefulWidget {
  const UserSignin({super.key});

  @override
  _UserSigninState createState() => _UserSigninState();
}

class _UserSigninState extends State<UserSignin> {
  bool _obscurePassword = true; // Controls whether the password is obscured

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Replace with your background image path
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Section
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'assets/logo.png', // Replace with your logo path
                      height: 100,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'HERBAPLANT',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  SizedBox(height: 30),

                  // Sign In Form Section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign In',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Log in to your account to access our premium and high-quality herbal experience.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: 15),

                        // Username Field
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.green),
                            labelText: 'Username',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Password Field
                        TextField(
                          obscureText: _obscurePassword, // Toggle visibility
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.green),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: const Color.fromARGB(255, 0, 0, 0),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword; // Toggle password visibility
                                });
                              },
                            ),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color.fromARGB(255, 0, 0, 0)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 12),

                        // Forgot Password Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Action for Forgot Password
                              print("Forgot Password button pressed");
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.green, fontSize: 14),
                            ),
                          ),
                        ),

                        // Login Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => MainNavigation()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black26)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Others',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.black26)),
                          ],
                        ),
                        SizedBox(height: 15),

                        // Register Button
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserSignup()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.green),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Register',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
