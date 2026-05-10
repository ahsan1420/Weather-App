import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onAnalyzeSky;
  final VoidCallback onSetBackground;
  final VoidCallback onPhotoLocation;

  const ActionButtons({
    super.key,
    required this.onAnalyzeSky,
    required this.onSetBackground,
    required this.onPhotoLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'analyze',
          onPressed: onAnalyzeSky,
          backgroundColor: Colors.white,
          tooltip: 'Analyze Sky (AI)',
          child: const Icon(Icons.camera_alt, color: Colors.blue),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'background',
          onPressed: onSetBackground,
          backgroundColor: Colors.white,
          tooltip: 'Set Background',
          child: const Icon(Icons.image, color: Colors.purple),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'photo_loc',
          onPressed: onPhotoLocation,
          backgroundColor: Colors.white,
          tooltip: 'Photo Location Weather',
          child: const Icon(Icons.photo_library, color: Colors.green),
        ),
      ],
    );
  }
}
