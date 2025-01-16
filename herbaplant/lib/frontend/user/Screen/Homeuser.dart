import 'package:flutter/material.dart';

class HomeUser extends StatelessWidget {
  const HomeUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: const Text('Herbal App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5.0),
            TextField(  
              decoration: InputDecoration(
                hintText: 'Search herbal plant',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final buttonSize = 70.0; 
                final crossAxisCount = width ~/ buttonSize; 
                return GridView.builder(
                  itemCount: features.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final feature = features[index];
                    return FeatureButton(
                      icon: feature['icon'] as IconData,
                      label: feature['label'] as String,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${feature['label']} clicked')),
                        );
                      },
                    );
                  },
                );
              },
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
                  Navigator.pop(context);
                  _handleCameraOption(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera selected')),
    );
  }

  void _handleGalleryOption(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery selected')),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const FeatureButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green,
            radius: 28,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

const features = [
  {'icon': Icons.health_and_safety, 'label': 'Diagnose'},
  {'icon': Icons.camera_alt, 'label': 'Identify'},
  {'icon': Icons.local_florist, 'label': 'My Garden'},
  {'icon': Icons.book, 'label': 'Books'},
  {'icon': Icons.notifications, 'label': 'Reminders'},
];
