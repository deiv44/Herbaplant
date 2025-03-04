import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:herbaplant/services/api_service.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  List<Map<String, dynamic>> searchHistory = [];
  List<Map<String, dynamic>> filteredHistory = [];

    @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  // Fetch history from API
  Future<void> fetchHistory() async {
    List<Map<String, dynamic>> history = await ApiService.fetchSearchHistory();
    setState(() {
      searchHistory = history;
      filteredHistory = history;
    });
  }

  // Search filter
  void filterSearch(String query) {
    setState(() {
      filteredHistory = searchHistory.where((plant) {
        return plant["plant_name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search History'),
        backgroundColor:  Colors.green.shade700,
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
              onChanged: filterSearch,
            ),
            SizedBox(height: 20),

            // Check if history is empty
            Expanded(
              child: filteredHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/historyn.json', // Ensure this file exists in assets
                            repeat: true,
                          ),
                          SizedBox(height: 10), // Space between animation and text
                          Text(
                            "No History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.history, color: Colors.green),
                            title: Text(filteredHistory[index]["plant_name"]),
                            subtitle: Text("Confidence: ${filteredHistory[index]["confidence"]}%"),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(plantName: filteredHistory[index]["plant_name"]),
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
        backgroundColor: Colors.green.shade700,
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
