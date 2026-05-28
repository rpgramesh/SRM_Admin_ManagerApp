import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final Function(String) onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(category),
      selected: isSelected,
      onSelected: (_) => onSelected(category),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.deepOrange.withOpacity(0.2),
      checkmarkColor: Colors.deepOrange,
      labelStyle: TextStyle(
        color: isSelected ? Colors.deepOrange : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.deepOrange : Colors.transparent,
          width: 1,
        ),
      ),
    );
  }
}