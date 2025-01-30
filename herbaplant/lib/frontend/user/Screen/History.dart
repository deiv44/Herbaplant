import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

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
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center, // Centers the column
          children: [
            Text(
              'Your Plant History:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with actual data for plant history
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.green),
                      title: Text('Plant History ${index + 1}'),
                      subtitle: Text('Description of history for Plant ${index + 1}'),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to DetailsScreen when tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(plantIndex: index + 1),
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
  final int plantIndex;

  const DetailsScreen({super.key, required this.plantIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plant ${plantIndex} Details'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Details for Plant $plantIndex',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}
