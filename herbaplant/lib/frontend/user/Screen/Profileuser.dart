import 'package:flutter/material.dart';
import '../../Auth/UserSignin.dart';

// Adjust the path as necessary

class ProfileUserScreen extends StatelessWidget {
  const ProfileUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child:
                        const Icon(Icons.person, size: 60, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Coffeestories',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'mark.brock@icloud.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Edit profile',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.grey),

            // Inventories Section
            SectionHeader(title: 'Inventories'),
            ListTile(
              leading: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.store, color: Colors.green),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: const Text('My stores'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ),
            ListTile(
              leading: const Icon(Icons.support_agent, color: Colors.green),
              title: const Text('Support'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ),

            const Divider(height: 1, color: Colors.grey),

            // Preferences Section
            SectionHeader(title: 'Preferences'),
            SwitchListTile(
              activeColor: Colors.green,
              title: const Text('Push notifications'),
              value: true,
              onChanged: (bool value) {},
            ),
            SwitchListTile(
              activeColor: Colors.green,
              title: const Text('Face ID'),
              value: true,
              onChanged: (bool value) {},
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.green),
              title: const Text('PIN Code'),
              onTap: () {},
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // Logout Section
            Center(
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  foregroundColor: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Logout'),
                        content:
                            const Text('Are you sure you want to log out?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                            child: const Text('Cancel',
                                style: TextStyle(color: Colors.green)),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserSignin(),
                                ),
                              );
                            },
                            child: const Text('Logout',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }
}
