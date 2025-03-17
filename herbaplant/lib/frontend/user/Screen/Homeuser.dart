import 'package:flutter/material.dart';
import 'package:herbaplant/services/api_service.dart';
import 'main_navigation.dart';
import 'package:lottie/lottie.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

import 'notification_service.dart';

class HomeUser extends StatefulWidget {
  const HomeUser({super.key});

  @override
  State<HomeUser> createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> with SingleTickerProviderStateMixin {
  late AnimationController _lottieController;

  String userName = "User"; 

  @override
  void initState() {
    super.initState();

    // Initialize Lottie animation controller
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _lottieController.stop();
      }
    });

    // Fetch user info
    _fetchUserInfo();

    // Fetch trending news
    _fetchTrendingNews();
  }


  void _fetchUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("  No token found in SharedPreferences");
      return;
    }

    // final url = Uri.parse("http://172.20.10.7:5000/auth/user-info"); //uncomment for running thru mobile data
    final url = Uri.parse("http://192.168.100.203:5000/auth/user-info");
    
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        userName = data["username"] ?? "Unknown";
      });
    } else {
      print("  Failed to fetch user info: ${response.body}");
    }
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  List<dynamic> trendingNews = [];

    void _fetchTrendingNews() async {
  List<dynamic> fetchedNews = await ApiService.fetchTrendingNews();

  if (fetchedNews.isNotEmpty) {
    // Check if new news is available
    if (trendingNews.isEmpty || fetchedNews.first["title"] != trendingNews.first["title"]) {
      // Show notification for new trending news
      NotificationService.showNotification(
        "New Trending News!",
        fetchedNews.first["title"],
      );
    }
  }

  setState(() {
    trendingNews = fetchedNews;
  });
}



    void _openNewsArticle(String url) async {
      final Uri uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print("Could not launch $url");
      }
    }
    


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor:  Colors.green.shade700,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Hi, $userName", // Display user's name
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              width: 50,
              height: 50,
              child: Lottie.asset(
                'assets/animations/growplant.json',
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController
                    ..duration = composition.duration
                    ..forward();
                },
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'What\'s New?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            SizedBox(
              height: 250,
              child: trendingNews.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(16.0),
                       itemCount: trendingNews.length > 3 ? 3 : trendingNews.length,
                      itemBuilder: (context, index) {
                        final article = trendingNews[index];
                        return GestureDetector(
                          onTap: () => _openNewsArticle(article["url"]),
                          child: Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      article["image"] ?? "https://via.placeholder.com/250",
                                      width: 250,
                                      height: 150,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 250,
                                          height: 150,
                                          color: Colors.grey[300],
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(Icons.broken_image, color: Colors.red, size: 40),
                                                const SizedBox(height: 5),
                                                const Text(
                                                  "Image failed to load",
                                                  style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),


                                ),
                                const SizedBox(height: 10),
                                Text(
                                  article["title"] ?? "No Title",
                                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(
                                    article["description"] ?? "No description available",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Get Started',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16.0),
                itemCount: 5,
                itemBuilder: (context, index) {
                  List<String> descriptions = [
                    'Learn how to take a clear photo for identification.',
                    'Understand how to analyze the results effectively.',
                    'Discover additional information about herbs.',
                    'Save your identification history for future reference.',
                    'Explore expert tips on herbal plant usage.',
                  ];
                  return GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 250,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'assets/image/Getstart${index + 1}.png',
                                width: 250,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Step ${index + 1}',
                            style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              descriptions[index],
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.black, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureBox(BuildContext context, IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        final mainNavState = context.findAncestorStateOfType<MainNavigationState>();
        if (mainNavState != null) {
          mainNavState.setSelectedIndex(index);
        }
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black, size: 40),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
