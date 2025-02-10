// import 'dart:io'; // Import for File handling
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '/services/api_service.dart';

// class Diagnose extends StatefulWidget {
//   @override
//   _DiagnoseState createState() => _DiagnoseState();
// }

// class _DiagnoseState extends State<Diagnose> {
//   File? _image; // Stores the selected image
//   String? _prediction; // Stores AI prediction result

//   // Function to Pick Image from Gallery
//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() => _image = File(pickedFile.path));
//         await _predictPlant(); // Call prediction after selecting image
//       }
//     } catch (e) {
//       print(" Error picking image: $e");
//     }
//   }

//   // Function to Predict Plant using API
//   Future<void> _predictPlant() async {
//     if (_image == null) return; // Prevents null errors

//     try {
//       String result = await ApiService.predictPlant(_image!);
//       setState(() => _prediction = result);
//     } catch (e) {
//       print(" Error in AI prediction: $e");
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Diagnose'),
//         backgroundColor: Colors.green,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Enter Your Symptoms:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//             SizedBox(height: 10),
//             TextField(
//               maxLines: 5,
//               decoration: InputDecoration(
//                 hintText: 'Describe your symptoms here...',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 // Add Diagnose logic
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//               child: Text('Analyze'),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Suggested Herbs:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: 3,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text('Herb ${index + 1}'),
//                     subtitle: Text('Useful for symptom relief.'),
//                     leading: Icon(Icons.local_florist, color: Colors.green),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
