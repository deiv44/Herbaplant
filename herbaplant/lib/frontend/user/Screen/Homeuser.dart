import 'package:flutter/material.dart';

class HomeUser extends StatelessWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Herbal'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Using herbs can offer natural, plant-based solutions for various health issues and promote overall wellness.',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search herbal plant',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView(
                children: const [
                  HerbalCard(
                    name: 'Ginger',
                    description:
                        'Commonly used to relieve nausea, improve digestion, and reduce inflammation.',
                  ),
                  HerbalCard(
                    name: 'Lagundi (Vitex negundo)',
                    description:
                        'Used for cough, asthma, and other respiratory issues.',
                  ),
                  HerbalCard(
                    name: 'Sambong (Blumea balsamifera)',
                    description:
                        'Known for treating kidney stones and as a diuretic.',
                  ),
                  HerbalCard(
                    name: 'Tsaang Gubat (Ehretia microphylla)',
                    description:
                        'Used for treating stomach pain and diarrhea.',
                  ),
                  HerbalCard(
                    name: 'Akapulko (Cassia alata)',
                    description:
                        'Commonly used for fungal infections like ringworm and athlete’s foot.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOptions(context),
        child: const Icon(Icons.qr_code_scanner),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _handleCameraOption(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context); // Close the modal
                  _handleGalleryOption(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleCameraOption(BuildContext context) {
    // Handle the camera option here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera selected')),
    );
  }

  void _handleGalleryOption(BuildContext context) {
    // Handle the gallery option here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery selected')),
    );
  }
}

class HerbalCard extends StatelessWidget {
  final String name;
  final String description;

  const HerbalCard({
    Key? key,
    required this.name,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              description,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 16.0),
                SizedBox(width: 4.0),
                Text(
                  'Approved by DOH',
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
