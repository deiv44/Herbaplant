import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<String> plantHistory = []; // Initially empty, add data dynamically

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant History'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search plant history...",
                prefixIcon: Icon(Icons.search, color: Colors.green),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) {
                // Implement search functionality here
              },
            ),
            SizedBox(height: 20),

            // Check if history is empty
            Expanded(
              child: plantHistory.isEmpty
                  ? Center(
                      child: Lottie.asset(
                        'assets/animations/historyn.json', // Ensure this file exists in assets
                        repeat: true,
                      ),
                    )
                  : ListView.builder(
                      itemCount: plantHistory.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.history, color: Colors.green),
                            title: Text(plantHistory[index]),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(
                                      plantName: plantHistory[index]),
                                ),
                              );
                            },
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
}

class DetailsScreen extends StatelessWidget {
  final String plantName;

  const DetailsScreen({super.key, required this.plantName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantName),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Details for $plantName',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
