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
        return plant["common_name"].toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  // Clear search history
  // Show confirmation before deleting history
  Future<void> clearHistory() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete all history?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
              child: const Text("Cancel", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      bool success = await ApiService.clearSearchHistory();
      if (success) {
        setState(() {
          searchHistory.clear();
          filteredHistory.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Search history deleted successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to delete search history.")),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Search History',
          style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () => clearHistory(),
          )
        ],
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
                            title: Text(filteredHistory[index]["common_name"]), 
                            subtitle: Text(filteredHistory[index]["scientific_name"]), 
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(plantData: filteredHistory[index]),
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
  final Map<String, dynamic> plantData;

  const DetailsScreen({super.key, required this.plantData});

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          plantData["common_name"],
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.green.shade700,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.delete, color: Colors.white),
        //     onPressed: () => _confirmDelete(context, plantData["id"]),
        //   ),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSectionTitle("Plant Identification"),
              buildTableRow("Common Name", plantData["common_name"]),
              buildTableRow("Scientific Name", plantData["scientific_name"]),
              buildTableRow("Local Name", plantData["local_names"]),

              buildSectionTitle("Appearance Identification"),
              buildTableRow("Leaf Shape", plantData["leaf_shape"]),
              buildTableRow("Flower Color", plantData["flower_color"]),
              buildTableRow("Plant Height", plantData["plant_height"]),
              buildTableRow("Growth Habit", plantData["growth_habit"]),
              buildTableRow("Distinctive Features", plantData["distinctive_features"]),

              buildSectionTitle("Geographic and Environmental Data"),
              buildTableRow("Native Region", plantData["native_region"]),
              buildTableRow("Habitat", plantData["habitat"]),
              buildTableRow("Climate Preference", plantData["climate_preference"]),
              buildTableRow("Soil Type", plantData["soil_type"]),
              buildTableRow("Sunlight Requirement", plantData["sunlight_requirement"]),

              buildSectionTitle("Usage and Benefits"),
              buildTableRow("Medicinal Uses", plantData["medicinal_uses"]),
            ],
          ),
        ),
      ),
    );
  }

  // Show confirmation dialog before deleting
  void _confirmDelete(BuildContext context, dynamic historyId) {
    print(" Deleting entry with ID: $historyId"); // Debugging

    if (historyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Error: Invalid history entry.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this entry from history?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Cancel
              child: const Text("Cancel", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                bool success = await ApiService.deleteSearchHistory(historyId);
                if (success) {
                  Navigator.of(context).pop(); // Go back to history list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Entry deleted successfully!")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete entry.")),
                  );
                }
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }


  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }

  Widget buildTableRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value ?? "N/A",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
