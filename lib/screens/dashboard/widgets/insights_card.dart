import 'package:flutter/material.dart';
import 'package:smart_healthcare_system/models/health_data_model.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';

class InsightsCard extends StatelessWidget {
  final HealthData? latestData;
  final VoidCallback onViewMore;

  const InsightsCard({
    super.key,
    this.latestData,
    required this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    String insightText = 'Connect your device to get personalized health insights.';
    IconData insightIcon = Icons.lightbulb_outline;
    Color insightColor = Theme.of(context).colorScheme.primary;
    
    if (latestData != null) {
      if (!latestData!.isHeartRateNormal) {
        insightText = latestData!.heartRate > 100
            ? 'Your heart rate is elevated. Try deep breathing exercises to help it return to normal.'
            : 'Your heart rate is lower than normal. Consider gentle movement or consult a doctor if you feel dizzy.';
        insightIcon = Icons.favorite;
        insightColor = Theme.of(context).colorScheme.error;
      } else if (!latestData!.isSpO2Normal) {
        insightText = 'Your blood oxygen level is lower than optimal. Try to get fresh air and practice deep breathing.';
        insightIcon = Icons.air;
        insightColor = Theme.of(context).colorScheme.error;
      } else if (!latestData!.isTemperatureNormal) {
        insightText = latestData!.temperature > 37.2
            ? 'Your body temperature is elevated. Rest and stay hydrated.'
            : 'Your body temperature is lower than normal. Keep warm and monitor for changes.';
        insightIcon = Icons.thermostat;
        insightColor = Theme.of(context).colorScheme.error;
      } else if (!latestData!.isStressLevelNormal) {
        insightText = 'Your stress levels are elevated. Consider taking a break for meditation or deep breathing.';
        insightIcon = Icons.psychology;
        insightColor = Theme.of(context).colorScheme.error;
      } else {
        insightText = 'All your vital signs are within normal ranges. Keep up the good work!';
        insightIcon = Icons.check_circle;
        insightColor = Theme.of(context).colorScheme.secondary;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Health Insights',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewMore,
                child: const Text('View More'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: insightColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  insightIcon,
                  color: insightColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  insightText,
                  style: AppTextStyles.body2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

