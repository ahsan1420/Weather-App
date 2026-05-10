import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Column(
        children: [
          Icon(
            Icons.cloud_outlined,
            size: 100,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 20),
          Text(
            'Search for a city,\nuse 📍 location, or 📷 analyze sky',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
