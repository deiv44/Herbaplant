import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';


class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000";

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
        print("⚠️ Failed to fetch user info: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Network error: $e");
      return false;
    }
  }

  // Update first_time_login to false after onboarding
  static Future<void> updateFirstTimeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("No token found, skipping first-time login update.");
      return;
    }

    final url = Uri.parse("$baseUrl/auth/update-first-time-login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        print("Successfully updated first_time_login to false.");
      } else {
        print("Failed to update first_time_login: ${response.body}");
      }
    } catch (e) {
      print("Network error: $e");
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

    var url = Uri.parse("http://127.0.0.1:5000/plant/predict");

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Content-Type'] = 'multipart/form-data';  

    request.files.add(await http.MultipartFile.fromPath(
      'file', imageFile.path,
      contentType: MediaType('image', 'jpeg'),
    ));

    // Debugging logs - wag muna tanggaling
    print("📸 Sending image: ${imageFile.path}");
    print("🔗 URL: $url");
    print("🛠 Headers: ${request.headers}");
    print("📤 Sending request...");

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
      print("⚠️ Network/Processing Error: $e");
      return {"error": "Prediction failed due to an error."};
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
      return "⚠️ Network error: $e";
    }
  }

  // User Login
  static Future<String?> loginUser(String email, String password) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data["token"];

      // Save token in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      print("Token saved: $token");

      return token;
    } else {
      print("⚠️ Login failed: ${response.body}");
      return null;
    }
  }

  // Logout and Clear Token
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    print("🔓 Token cleared.");
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

}
