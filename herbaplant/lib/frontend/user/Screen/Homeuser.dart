import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:lottie/lottie.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  List<Map<String, dynamic>> messages = []; // Stores chat messages
  TextEditingController messageController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  String? _result; // Prediction result
  File? _image; // Selected image file
  bool _isLoading = false; // Loading state
  bool _hasUserInteracted = false; // Controls the visibility of welcome UI

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  // Load the TFLite model
  Future<void> _loadModel() async {
    try {
      String? result = await Tflite.loadModel(
        model: "assets/models/model.tflite",
        labels: "assets/models/labels.txt",
      );
      print("Model loaded: $result");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Handle media selection (camera/gallery)
  void _selectMedia(ImageSource source) async {
    XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        messages.add({'type': 'image', 'content': pickedFile.path});
        _hasUserInteracted = true; // Hide welcome UI after selection
      });

      await _predictImage(imageFile);
    }
  }

  // Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.green),
            title: const Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              _selectMedia(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.green),
            title: const Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _selectMedia(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  // Process and predict image
  Future<void> _predictImage(File image) async {
    setState(() {
      _isLoading = true;
      _hasUserInteracted = true; // Hide Hi, User & Lottie after interaction
    });

    try {
      var predictions = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 5,
        threshold: 0.5,
      );

      setState(() {
        if (predictions != null && predictions.isNotEmpty) {
          _result = predictions.first['label'];
          messages.add({'type': 'text', 'content': "Prediction: $_result"});
        } else {
          _result = "No match found!";
          messages.add({'type': 'text', 'content': "Prediction: No match found!"});
        }
      });
    } catch (e) {
      print("Error during prediction: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _scrollToBottom();
  }

  // Send text message
  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'content': messageController.text});
        messageController.clear();
        _hasUserInteracted = true; // Hide welcome UI after message sent
      });
      _scrollToBottom();
    }
  }

  // Scroll to bottom of chat
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Herbaplant',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(color: Colors.green),

          // Show welcome message & Lottie only if user hasn't interacted
          if (!_hasUserInteracted) ...[
            const SizedBox(height: 20),
            const Text(
              "Hi, User",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            const Text(
              "Identify Herbal Plant in your local area!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Lottie.asset("assets/animations/scanplanta.json", width: 200, height: 200),
            const SizedBox(height: 20),
          ],

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: message['type'] == 'text'
                          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
                          : EdgeInsets.zero,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: message['type'] == 'text'
                          ? Text(
                              message['content'],
                              style: const TextStyle(color: Colors.black, fontSize: 16),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(message['content']),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat input section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.green),
                  onPressed: _showImageSourceDialog,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: messageController,
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
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send, color: Colors.green, size: 28),
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
