import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import the image_picker package
import 'dart:io'; // For File handling

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  String currentMessage = '';  // Variable to hold the current message
  TextEditingController messageController = TextEditingController(); // Controller for text input
  bool _messageSent = false;  // Variable to track if the message is sent
  ScrollController _scrollController = ScrollController(); // Controller for scrolling
  GlobalKey _clipButtonKey = GlobalKey();  // Key to track the position of the clip button
  final ImagePicker _picker = ImagePicker(); // Instance of ImagePicker
  
  void _showInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('App Info'),
        content: const Text('This is the Herbaplant app where you can chat with the plant assistant.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Function to handle image selection or camera opening
  void _selectMedia(String option) async {
    if (option == 'image') {
      // Pick an image from the gallery
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          currentMessage = 'Image selected: ${pickedFile.name}';  // Set the message with the selected image
          _messageSent = true;
        });
      }
    } else if (option == 'camera') {
      // Take a photo using the camera
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          currentMessage = 'Camera image taken: ${pickedFile.name}';  // Set the message with the camera image
          _messageSent = true;
        });
      }
    }

    // Scroll to the bottom after the message
    _scrollToBottom();
  }

  // Function to scroll to the bottom of the chat when a new message is added
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  // Function to show media options above the clip button
  void _showMediaOptions(BuildContext context) {
    final RenderBox renderBox = _clipButtonKey.currentContext?.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero); // Get the position of the clip button

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy - 80, 0, 0), // Position above the clip button
      items: [
        PopupMenuItem<String>(
          value: 'image',
          child: Row(
            children: const [
              Icon(Icons.image, color: Colors.black),
              SizedBox(width: 8),
              Text('Select Image'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: const [
              Icon(Icons.camera_alt, color: Colors.black),
              SizedBox(width: 8),
              Text('Open Camera'),
            ],
          ),
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        _selectMedia(value);  // Handle image/camera selection
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 225, 255, 219),
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Herbaplant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info, color: Colors.white),
            onPressed: _showInfo, // Call the function when clicked
          ),
        ],
      ),
      body: Column(
        children: [
          // Display greeting text if message is not sent
          if (!_messageSent)
            Expanded(
              child: Center(
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello, ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: 'Herbaplant User',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Chat message section showing the current message
          Expanded(
            child: ListView(
              controller: _scrollController,  // Attach the scroll controller
              children: [
                if (currentMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Align(
                      alignment: Alignment.center, // Center the message text
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentMessage,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Chat input and send button
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Clip Icon Button on the left side
                IconButton(
                  key: _clipButtonKey,  // Attach the key to track the position
                  icon: const Icon(Icons.attach_file, color: Colors.green),
                  onPressed: () {
                    _showMediaOptions(context);  // Show media options when clicked
                  },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: messageController,  // Controller to manage the input
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      setState(() {
                        currentMessage = messageController.text;  // Set the current message as the new one
                        _messageSent = true;  // Hide the greeting when the message is sent
                      });
                      messageController.clear();  // Clear the input field
                      _scrollToBottom();  // Scroll to the bottom after adding a new message
                    }
                  },
                  icon: const Icon(
                    Icons.send,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: HomeUser(),
    debugShowCheckedModeBanner: false,
  ));
}
