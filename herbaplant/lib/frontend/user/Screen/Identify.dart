import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '/services/api_service.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';


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

  Widget formatMessage(String message) {
    return MarkdownBody(
      data: message,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: 16, color: Colors.black),
        strong: TextStyle(fontWeight: FontWeight.bold), // **bold**
        em: TextStyle(fontStyle: FontStyle.italic), // *italic*
      ),
    );
  }



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
      colorShadow: const Color.fromRGBO(76, 175, 80, 1),
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
    print("API Response: $result");

    if (result == null || result.containsKey("error")) {
      setState(() {
        messages.add({
          'type': 'text',
          'content': "Prediction failed: ${result?['error'] ?? 'Unknown error'}"
        });
      });
      return;
    }

    // Extract plant details with default fallbacks
    String plantName = result['common_name']?.toString() ?? "an unknown plant";
    String scientificName = result['scientific_name']?.toString() ?? "Unknown Scientific Name";
    String localNames = result['local_names']?.toString() ?? "N/A";
    String leafShape = result['leaf_shape']?.toString() ?? "Unknown";
    String flowerColor = result['flower_color']?.toString() ?? "Unknown";
    String plantHeight = result['plant_height']?.toString() ?? "Unknown";
    String growthHabit = result['growth_habit']?.toString() ?? "Unknown";
    String distinctiveFeatures = result['distinctive_features']?.toString() ?? "No distinctive features";
    String nativeRegion = result['native_region']?.toString() ?? "Unknown region";
    String habitat = result['habitat']?.toString() ?? "Unknown habitat";
    String climatePreference = result['climate_preference']?.toString() ?? "Unknown climate preference";
    String soilType = result['soil_type']?.toString() ?? "Unknown soil type";
    String sunlightRequirement = result['sunlight_requirement']?.toString() ?? "Unknown sunlight requirement";
    String medicinalUses = result['medicinal_uses']?.toString() ?? "No known medicinal uses.";

    // Define 10 different description styles
    List<String> templates = [
      "**$plantName**, scientifically known as ***$scientificName***, features $leafShape leaves and exquisite $flowerColor flowers. Typically growing up to $plantHeight, it is distinguished by $distinctiveFeatures. This plant is commonly found in $habitat and thrives in $soilType under $sunlightRequirement conditions.",

      "Introducing **$plantName** (***$scientificName***), a plant recognized for its $distinctiveFeatures. It naturally flourishes in $habitat, particularly in $climatePreference environments. Its $flowerColor flowers and $leafShape leaves contribute to its unique appearance.",

      "The plant you have identified is **$plantName**, botanically classified as ***$scientificName***. With a $growthHabit growth habit, it can reach a height of $plantHeight. It is primarily found in $nativeRegion and is noted for $distinctiveFeatures.",

      "**$plantName** is a remarkable species with $flowerColor flowers and $leafShape leaves. Commonly found in $habitat, it thrives in $climatePreference conditions. In traditional medicine, it is valued for its medicinal benefits, particularly for $medicinalUses.",

      "Ah! You’ve identified **$plantName**, known scientifically as ***$scientificName***. It is predominantly found in $nativeRegion, where it grows as a $growthHabit plant. This species is recognized for $distinctiveFeatures and is widely utilized for $medicinalUses.",

      "**$plantName** (***$scientificName***) is a well-documented species featuring $flowerColor flowers and a distinctive $growthHabit growth pattern. It flourishes in $soilType and is most commonly observed in $habitat.",

      "You have identified **$plantName**, an exceptional plant known for $distinctiveFeatures and striking $flowerColor blossoms. Preferring $climatePreference conditions, it requires $sunlightRequirement for optimal development.",

      "**$plantName**, classified as ***$scientificName***, is indigenous to $nativeRegion, where it thrives in $habitat. With $leafShape leaves and a maximum height of $plantHeight, it adapts well to $soilType and is valued for $medicinalUses.",

      "The plant in question is **$plantName**, a species belonging to ***$scientificName***. Adapted to $climatePreference climates, it produces $flowerColor flowers and is distinguished by $distinctiveFeatures, making it easily recognizable.",

      "This is **$plantName**, also referred to as '$localNames'. Predominantly found in $habitat, it is scientifically classified as ***$scientificName***. It thrives in $climatePreference conditions, requiring $sunlightRequirement exposure for healthy growth."
  ];

    // Pick a random template
    Random random = Random();
    String randomDescription = templates[random.nextInt(templates.length)];
    
    String formatResponse(String text) {
      return text.replaceAllMapped(RegExp(r'([.!?]) '), (match) => "${match.group(1)}\n\n");
    }


    setState(() {
      messages.add({'type': 'text', 'content': formatResponse(randomDescription)});
    });



  } catch (e) {
    print(" Error during prediction: $e");
    setState(() {
      messages.add({'type': 'text', 'content': "Prediction failed. Try again."});
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
                "Identify Herbal Plants\nby Taking or Uploading a Photo!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
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
              child: 
              ListView.builder(
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
                          ? MarkdownBody(
                              data: message['content'], // ✅ Now supports bold & italic!
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(fontSize: 16, color: Colors.black),
                                strong: TextStyle(fontWeight: FontWeight.bold), // **bold**
                                em: TextStyle(fontStyle: FontStyle.italic), // *italic*
                              ),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // ✅ Center buttons
                    children: [
                      Column(
                        children: [
                          // 📸 Camera Icon (Take Photo)
                          IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Colors.green, size: 50), // ✅ New icon
                            onPressed: () => _selectMedia(ImageSource.camera),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Take a Photo",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40), // Space between buttons
                      Column(
                        children: [
                          // 🖼️ Upload Icon (Upload Photo)
                          IconButton(
                            icon: const Icon(Icons.upload_file_rounded, color: Colors.green, size: 50), // ✅ New icon
                            onPressed: () => _selectMedia(ImageSource.gallery),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            "Upload a Photo",
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
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
