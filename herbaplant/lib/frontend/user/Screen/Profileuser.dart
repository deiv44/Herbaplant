import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/api_service.dart';
import 'package:herbaplant/main.dart' show navigatorKey;


class ProfileUserScreen extends StatefulWidget {
  const ProfileUserScreen({super.key});

  @override
  _ProfileUserScreenState createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  bool _pushNotifications = true;
  String _username = "Loading...";
  String _email = "Loading...";
  bool _showUsernameFields = false;
  bool _showEmailFields = false;
  bool _showPasswordFields = false;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureRetypePassword = true;

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String? _passwordError;

  @override
    void initState() {
      super.initState();
      _fetchUserInfo();
    }

    void _fetchUserInfo() async {
      final userInfo = await ApiService.getUserInfo();
      if (userInfo != null) {
        setState(() {
          _username = userInfo["username"] ?? "Unknown";
          _email = userInfo["email"] ?? "Unknown";
        });
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white), // ✅ White Logout Icon
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _logout();
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _ProfileSection(username: _username, email: _email), 

          const Divider(height: 40, color: Colors.grey),

          const _SectionHeader(title: 'Profile Management'),

          // Change Username
          ExpansionTile(
            leading: const Icon(Icons.person, color: Colors.green),
            title: const Text('Change Username'),
            children: _showUsernameFields ? _buildUsernameFields() : [],
            onExpansionChanged: (expanded) {
              setState(() {
                _showUsernameFields = expanded;
              });
            },
          ),

          // Change Email
          ExpansionTile(
            leading: const Icon(Icons.email, color: Colors.green),
            title: const Text('Change Email'),
            children: _showEmailFields ? _buildEmailFields() : [],
            onExpansionChanged: (expanded) {
              setState(() {
                _showEmailFields = expanded;
              });
            },
          ),


          // Change Password
          ExpansionTile(
            leading: const Icon(Icons.lock, color: Colors.green),
            title: const Text('Change Password'),
            children: _showPasswordFields ? _buildPasswordFields() : [],
            onExpansionChanged: (expanded) {
              setState(() {
                _showPasswordFields = expanded;
              });
            },
          ),

          const Divider(height: 20, color: Colors.grey),

          const _SectionHeader(title: 'App Preferences'),
          SwitchListTile(
            activeColor: Colors.green,
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            onChanged: (bool value) {
              setState(() {
                _pushNotifications = value;
              });
            },
          ),

          const Divider(height: 20, color: Colors.grey),

          // Center(
          //   child: TextButton.icon(
          //     style: TextButton.styleFrom(
          //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          //       foregroundColor: Colors.red,
          //     ),
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: const Text('Confirm Logout'),
          //             content: const Text('Are you sure you want to log out?'),
          //             actions: [
          //               TextButton(
          //                 onPressed: () => Navigator.of(context).pop(),
          //                 child: const Text('Cancel', style: TextStyle(color: Colors.green)),
          //               ),
          //               TextButton(
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                   _logout();
          //                 },
          //                 child: const Text('Logout', style: TextStyle(color: Colors.red)),
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //     },
          //     icon: const Icon(Icons.logout),
          //     label: const Text('Logout'),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Build Username Change Fields
List<Widget> _buildUsernameFields() {
  return [
    _buildExpansionContent([
      const Text("Enter New Username", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      TextField(
        controller: usernameController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          _updateUserInfo("username", usernameController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Save Username", style: TextStyle(color: Colors.white)),
      ),
    ]),
  ];
}

  // Build Email Change Fields
  List<Widget> _buildEmailFields() {
  return [
    _buildExpansionContent([
      const Text("Enter New Email Address", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 5),
      TextField(
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        "⚠️ You will be logged out and need to verify your new email before logging in again.",
        style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          _updateUserInfo("email", emailController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Save Email", style: TextStyle(color: Colors.white)),
      ),
    ]),
  ];
}

  // Build Password Change Fields
  List<Widget> _buildPasswordFields() {
  return [
    _buildExpansionContent([
      _passwordInputField("Old Password", oldPasswordController, _obscureOldPassword, () {
        setState(() {
          _obscureOldPassword = !_obscureOldPassword;
        });
      }),
      _passwordInputField("New Password", newPasswordController, _obscureNewPassword, () {
        setState(() {
          _obscureNewPassword = !_obscureNewPassword;
        });
      }),
      _passwordInputField("Retype New Password", retypePasswordController, _obscureRetypePassword, () {
        setState(() {
          _obscureRetypePassword = !_obscureRetypePassword;
        });
      }),
      if (_passwordError != null)
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
          child: Text(_passwordError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
        ),
      const SizedBox(height: 10),
      ElevatedButton(
        onPressed: () {
          if (newPasswordController.text != retypePasswordController.text) {
            setState(() {
              _passwordError = "Passwords do not match!";
            });
            return;
          } else {
            setState(() {
              _passwordError = null;
            });
          }
          _updateUserInfo("password", newPasswordController.text.trim());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text("Save Password", style: TextStyle(color: Colors.white)),
      ),
    ]),
  ];
}

    Widget _passwordInputField(
    String label, TextEditingController controller, bool obscureText, VoidCallback toggleVisibility) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[200],
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggleVisibility,
        ),
      ),
    ),
  );
}


    Future<void> _updateUserInfo(String field, String newValue) async {
      if (field == "email") {
        _showEmailUpdateDialog(newValue);
      } else {
        final success = await ApiService.updateUserInfo(field, newValue);
        if (success) {
          _fetchUserInfo();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$field updated successfully!")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update profile.")));
        }
      }
    }

    void _showEmailUpdateDialog(String newEmail) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("⚠️ Email Change Warning"),
            content: const Text(
              "You will be logged out and need to verify your new email before logging in again.\n\nAre you sure you want to update your email?",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(), 
                child: const Text("No", style: TextStyle(color: Colors.green)),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 
                  _showFullScreenLoading(); //

                  final success = await ApiService.updateUserInfo("email", newEmail);

                  if (success) {
                    debugPrint("  Email updated successfully.");
                    await Future.delayed(const Duration(milliseconds: 500)); 
                    _logout(); // 
                  } else {
                    debugPrint("  Failed to update email.");
                    if (mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Failed to update email.")),
                      );
                    }
                  }
                },
                child: const Text("Yes", style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }


  void _showFullScreenLoading() {
    showDialog(
      context: navigatorKey.currentContext!, 
      barrierDismissible: false, 
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, 
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.green),
                const SizedBox(height: 20),
                const Text(
                  "Logging out...\nPlease check your new email address for verification.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove("token");
  debugPrint("🔓 User logged out due to email change.");

  await Future.delayed(const Duration(milliseconds: 500)); 

  if (navigatorKey.currentContext != null) { // 
    WidgetsBinding.instance.addPostFrameCallback((_) { 
      GoRouter.of(navigatorKey.currentContext!).go('/login'); 
    });
  } else {
    debugPrint("⚠️ navigatorKey.currentContext is NULL. Skipping navigation.");
  }
}
}

class _ProfileSection extends StatelessWidget {
  final String username;
  final String email;

  const _ProfileSection({required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.green.shade100,
        child: const Icon(Icons.person, size: 50, color: Colors.green),
      ),
      title: Text(username, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      subtitle: Text(email, style: const TextStyle(color: Colors.grey)),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,              
          fontWeight: FontWeight.bold, 
          color: Colors.black,         
        ),
      ),
    );
  }
}

// Styled Container for better UI inside ExpansionTile
Widget _buildExpansionContent(List<Widget> children) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}