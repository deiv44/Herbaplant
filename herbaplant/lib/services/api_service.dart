import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';


class ApiService {
  // static const String baseUrl = "http://172.20.10.7:5000"; //uncomment if running in mobile data
  static const String baseUrl = "http://192.168.100.203:5000";


  // Fetch first_time_login from backend
  static Future<bool> checkFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("No token found, assuming user is not first-time.");
      return false;
    }

    final url = Uri.parse("$baseUrl/auth/user-info");

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["first_time_login"] ?? false;
      } else {
        print(" Failed to fetch user info: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Network error: $e");
      return false;
    }
  }

  // Update first_time_login to false after onboarding
  static Future<bool> updateFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("No token found in SharedPreferences");
      return false;
    }

    final url = Uri.parse("$baseUrl/auth/update-first-time-login");
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      print("First-time login updated successfully!");
      return true;
    } else {
      print("Failed to update first-time login: ${response.body}");
      return false;
    }
  }

  // Send Verification Email
    static Future<bool> sendVerificationEmail() async {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        print("No token found in SharedPreferences"); //debugging purposes
        return false;
      }

      final url = Uri.parse("$baseUrl/auth/send-verification");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
      );

      print("Response Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        print("Resent verification email!");
        return true;
      } else {
        print("Failed to resend verification email: ${response.body}");
        return false;
      }
    }

  // AI Model Prediction
  static Future<Map<String, dynamic>?> predictPlant(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("No token found! User might not be logged in.");
      return {"error": "Authentication error: Please log in first."};
    }

    var url = Uri.parse("$baseUrl/plant/predict");
    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';

    request.files.add(await http.MultipartFile.fromPath(
      'file', imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    print("Sending request to: $url");

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Response Status: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 200) {
        return json.decode(responseBody);
      } else {
        return {"error": "Prediction failed. Server response: $responseBody"};
      }
    } catch (e) {
      print("Network/Processing Error: $e");
      return {"error": "Prediction failed due to an error."};
    }
  }

  // Save search history API call
  static Future<void> saveSearchHistory(String plantName, String confidence) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print(" No token found");
      return;
    }

    final url = Uri.parse("$baseUrl/search-history/save");

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "plant_name": plantName,
          "confidence": confidence,
        }),
      );

      if (response.statusCode == 201) {
        print("Search history saved successfully!");
      } else {
        print("Failed to save search history: ${response.body}");
      }
    } catch (e) {
      print(" Network error: $e");
    }
  }

// Fetch Search History
  static Future<List<Map<String, dynamic>>> fetchSearchHistory() async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

  if (token == null) {
    print(" No token found");
    return [];
  }

  final url = Uri.parse("$baseUrl/plant/search-history/get");

  try {
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json"
    });

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);

      // Ensure each entry has an "id"
      List<Map<String, dynamic>> history = List<Map<String, dynamic>>.from(data);
      for (var entry in history) {
        if (!entry.containsKey("id")) {
          entry["id"] = null; // Prevents crashes
        }
      }

      return history;
    } else {
      print(" Failed to fetch history: ${response.body}");
      return [];
    }
  } catch (e) {
    print(" Network error: $e");
    return [];
  }
}

  // Delete all search history
  static Future<bool> clearSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print(" No token found");
      return false;
    }

    final url = Uri.parse("$baseUrl/plant/search-history/delete/all");

    try {
      final response = await http.delete(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      });

      if (response.statusCode == 200) {
        print(" Search history cleared!");
        return true;
      } else {
        print(" Failed to clear history: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Network error: $e");
      return false;
    }
  }

  // Delete a single search history entry
  static Future<bool> deleteSearchHistory(int historyId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print(" No token found");
      return false;
    }

    final url = Uri.parse("$baseUrl/plant/search-history/delete/$historyId");

    try {
      final response = await http.delete(url, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      });

      if (response.statusCode == 200) {
        print(" Entry deleted successfully!");
        return true;
      } else {
        print(" Failed to delete entry: ${response.body}");
        return false;
      }
    } catch (e) {
      print(" Network error: $e");
      return false;
    }
  }

  // Gnews API for Articles
  static const String gNewsApiKey = "c5169b26e80899bdb2210234b8ed11f1";

  static Future<List<dynamic>> fetchTrendingNews() async {
    final url = Uri.parse(
        "https://gnews.io/api/v4/top-headlines?country=ph&category=health&apikey=$gNewsApiKey");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["articles"] ?? [];
      } else {
        print(" Failed to fetch news: ${response.body}");
        return [];
      }
    } catch (e) {
      print(" Network error: $e");
      return [];
    }
  }

  // Register a New User
  static Future<String?> registerUser(String username, String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/register");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return "Registration successful!";
      } else {
        final error = jsonDecode(response.body)["error"] ?? "Registration failed!";
        return error;
      }
    } catch (e) {
      return " Network error: $e";
    }
  }

  // User Login
  static Future<Map<String, dynamic>?> loginUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");
    
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);  
    } else {
      return jsonDecode(response.body); 
    }
  }

  // Logout and Clear Token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    print("Token cleared.");
  }

  // Reset Password
  static Future<String> resetPassword(String token, String newPassword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password?token=$token'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"new_password": newPassword, "confirm_password": newPassword}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return "Password reset successful";
    } else {
      return data['error'] ?? "An error occurred";
    }
  }
  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/forgot-password'),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"email": email}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body); 
  } else {
    return {"message": "Failed to send email"}; 
  }
}

  // User Info
  static Future<Map<String, dynamic>?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("No token found in SharedPreferences");
      return null;
    }

    final url = Uri.parse("$baseUrl/auth/user-info");
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Failed to fetch user info: ${response.body}");
      return null;
    }
  }

  static Future<bool> updateUserInfo(String field, String newValue) async {
  final prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString("token");

    if (token == null) {
      print("  No token found in SharedPreferences");
      return false;
    }

    final url = Uri.parse("$baseUrl/auth/update-user");
    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode({field: newValue}),
    );

    if (response.statusCode == 200) {
      print("  $field updated successfully!");

      // Force logout if email is updated
      if (field == "email") {
        await prefs.remove("token"); 
        print("🔓 User logged out due to email change.");
      }

      return true;
    } else {
      print("  Failed to update $field: ${response.body}");
      return false;
    }
  }

}
