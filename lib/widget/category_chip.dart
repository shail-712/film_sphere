import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF6366F1)
                : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
