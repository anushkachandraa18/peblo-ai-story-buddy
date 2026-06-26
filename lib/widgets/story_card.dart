import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StoryCard extends StatelessWidget {
  final String storyText;

  const StoryCard({super.key, required this.storyText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "STORY TEXT APPEARS HERE",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Icon(Icons.menu_book_outlined,
                  size: 18, color: AppColors.primary.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            storyText,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: Color(0xFF2D2D2D),
            ),
          ),
        ],
      ),
    );
  }
}
