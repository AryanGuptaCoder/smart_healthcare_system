import 'package:flutter/material.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final List<Map<String, dynamic>> _meditations = [
    {
      'title': 'Deep Breathing',
      'duration': '5 min',
      'description': 'Simple breathing exercises to reduce stress and anxiety.',
      'icon': Icons.air,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Body Scan',
      'duration': '10 min',
      'description': 'Progressive relaxation technique for physical tension.',
      'icon': Icons.accessibility_new,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Mindful Walking',
      'duration': '15 min',
      'description': 'Walking meditation to promote mindfulness and peace.',
      'icon': Icons.directions_walk,
      'color': const Color(0xFF9C27B0),
    },
    {
      'title': 'Sleep Meditation',
      'duration': '20 min',
      'description': 'Gentle guidance to help you fall asleep naturally.',
      'icon': Icons.bedtime,
      'color': const Color(0xFF3F51B5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Guided Meditation',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Take a moment to relax and reduce stress',
            style: AppTextStyles.body1.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _meditations.length,
            itemBuilder: (context, index) {
              final meditation = _meditations[index];
              return _buildMeditationCard(meditation);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationCard(Map<String, dynamic> meditation) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Navigate to meditation session
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              color: meditation['color'].withOpacity(0.1),
              child: Center(
                child: Icon(
                  meditation['icon'],
                  size: 48,
                  color: meditation['color'],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          meditation['title'],
                          style: AppTextStyles.body1.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: meditation['color'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meditation['duration'],
                          style: AppTextStyles.caption.copyWith(
                            color: meditation['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meditation['description'],
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

