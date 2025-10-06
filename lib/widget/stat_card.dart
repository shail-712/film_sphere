import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatCard({
    Key? key,
    required this.icon,
    required this.value,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
