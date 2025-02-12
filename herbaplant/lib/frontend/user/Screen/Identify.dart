import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/services/api_service.dart';
import 'package:herbaplant/frontend/Auth/UserSignin.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class Identify extends StatefulWidget {
  const Identify({super.key});

  @override
  State<Identify> createState() => _IdentifyState();
}

class _IdentifyState extends State<Identify> {
  
  List<Map<String, dynamic>> messages = [];
  TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  String? _result;
  File? _image;
  bool _isLoading = false;
  bool _hasUserInteracted = false;
// Tutorial Coach Mark /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> targets = [];
  GlobalKey chatkey = GlobalKey();
  GlobalKey CameraKey = GlobalKey();
  GlobalKey Chatboxkey = GlobalKey();

  @override
  void initState() {
  super.initState();
  _initTarget(); // Initialize targets but don't start the tutorial yet
  }

  void _showTutorialCoachMark(){
    _initTarget();
    tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      pulseEnable: false,
      colorShadow: Colors.green,
      onClickTarget: (target) {
        print(target.identify);
      },
      hideSkip: false,
      onFinish: () {
        print("finish");
      },
    )..show(context: context);  
  }

  void _initTarget(){
    targets = [
      TargetFocus(
        identify: "chatbox-key",
        keyTarget: Chatboxkey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder:  (context, controller) {
              return CoachMarkDesc( 
                text: "Chat Box to communicate with the bot",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            } 
          ),
        ]
      ),

      TargetFocus(
        identify: "chat-key",
        keyTarget: chatkey,
        shape: ShapeLightFocus.RRect,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder:  (context, controller) {
              return CoachMarkDesc( 
                text: "Chat with the bot to identify plants",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            } 
          ),
        ]
      ),

      TargetFocus(
        identify: "camera-key",
        keyTarget: CameraKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder:  (context, controller) {
              return CoachMarkDesc( 
                text: "Click here to take a photo or Select of the plant you want to identify",
                onNext: () {
                  controller.next();
                },
                onSkip: () {
                  controller.skip();
                },
              );
            } 
          ),
        ]
      )
    ];
  }
  
  
      
// Tutorial Coach Mark /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // void _logout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove("token");
  //   debugPrint("🔓 Token cleared.");
  //   if (mounted) {
  //     GoRouter.of(context).go('/login');
  //   }
  // }

  void _selectMedia(ImageSource source) async {
    XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      print("📸 Selected Image Path: ${imageFile.path}");
      setState(() {
        _image = imageFile;
        messages.add({'type': 'image', 'content': pickedFile.path});
        _hasUserInteracted = true;
      });
      await Future.delayed(Duration(milliseconds: 500));
      await _predictImage(imageFile);
    }
  }

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

  Future<void> _predictImage(File image) async {
    setState(() {
      _isLoading = true;
      _hasUserInteracted = true;
    });
    try {
      Map<String, dynamic>? result = await ApiService.predictPlant(image);
      if (result == null || result.containsKey("error")) {
        setState(() {
          messages.add({
            'type': 'text',
            'content':
                "Prediction failed: ${result?['error'] ?? 'Unknown error'}"
          });
        });
        return;
      }
      String plantName = result['plant'] ?? "Unknown Plant";
      String family = result['family'] ?? "Unknown Family";
      String usage = result['usage'] ?? "No usage information available.";
      String benefits = result['benefits'] ?? "No benefits listed.";
      String confidence = result['confidence'] ?? "0%";
      String formattedMessage = """
        Detected Plant:  
        $plantName  
        Family:
        $family  
        Usage:  
        $usage  
        Benefits:  
        $benefits  
        Confidence: 
        $confidence  
        """;
      setState(() {
        _result = plantName;
        messages.add({'type': 'text', 'content': formattedMessage});
      });
    } catch (e) {
      print("⚠️ Error during prediction: $e");
      setState(() {
        messages
            .add({'type': 'text', 'content': " Prediction failed. Try again."});
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    _scrollToBottom();
  }

  void _sendMessage() {
    if (messageController.text.isNotEmpty) {
      setState(() {
        messages.add({'type': 'text', 'content': messageController.text});
        messageController.clear();
        _hasUserInteracted = true;
      });
      _scrollToBottom();
    }
  }

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
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Herbaplant',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          //IconButton(
          //icon: const Icon(Icons.logout, color: Colors.white),
          //onPressed: _logout,
          //),
           
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showTutorialCoachMark,
          ),
        ],
      
        
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(color: Colors.green),

          // Show welcome message & Lottie only if user hasn't interacted
          if (!_hasUserInteracted) ...[
            // const Text(
            //   "Hi, User",
            //   style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            // ),

            const SizedBox(height: 8),
            const Text(
              "Identify Herbal Plant in your local area!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Lottie.asset("assets/animations/scanplanta.json",
                width: 200, height: 200),
            const SizedBox(height: 20),
          ],

          // Chat messages
          Container(
            key: Chatboxkey ,
            child: Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: message['type'] == 'text'
                            ? const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0)
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
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 16),
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
          ),

          // Chat input section
          Container(
            key: chatkey,
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  key: CameraKey,
                  child: IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.green),
                    onPressed: _showImageSourceDialog,
                  ),
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



class CoachMarkDesc extends StatefulWidget {
  const CoachMarkDesc({
    super.key,
    required this.text,
    this.skip = "Skip",
    this.next = "Next",
    this.onSkip,
    this.onNext,
  });

  final String text;
  final String skip;
  final String next;
  final void Function()? onSkip;
  final void Function()? onNext;

  @override
  State<CoachMarkDesc> createState() => _CoachMarkDescState();
}

class _CoachMarkDescState extends State<CoachMarkDesc> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override 
   void initState() {
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 20,
      duration: const Duration(milliseconds: 500),
    )..repeat(min: 0, max: 20, reverse: true);
    super.initState();
  
   }
  @override 
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value),
          child: child,
        );
      },
      child: Container(
        padding: const  EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row( 
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onSkip,
                  child: Text(widget.skip),
                ),
                TextButton(
                  onPressed: widget.onNext,
                  child: Text(widget.next),
                ),
              ],
            ),
          ],
        ),
      
      ),
    );
  }
}