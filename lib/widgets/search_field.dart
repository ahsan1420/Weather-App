import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onClear;
  final VoidCallback onLocationTap;
  final ValueChanged<String> onChanged;

  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmit,
    required this.onClear,
    required this.onLocationTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search city...',
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              ),
            IconButton(
              icon: const Icon(Icons.my_location, color: Colors.blue),
              onPressed: onLocationTap,
              tooltip: 'My location',
            ),
          ],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputBorderRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
