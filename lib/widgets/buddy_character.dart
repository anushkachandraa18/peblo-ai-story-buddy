import 'package:flutter/material.dart';
import '../providers/story_provider.dart';
import '../theme/app_theme.dart';

class BuddyCharacter extends StatelessWidget {
  final BuddyState state;

  const BuddyCharacter({super.key, required this.state});

  IconData _getIcon() {
    switch (state) {
      case BuddyState.idle:
        return Icons.smart_toy_outlined;
      case BuddyState.loadingAudio:
        return Icons.hourglass_top;
      case BuddyState.playingAudio:
        return Icons.smart_toy;
      case BuddyState.audioFailed:
        return Icons.sentiment_dissatisfied;
      case BuddyState.quizVisible:
        return Icons.smart_toy;
      case BuddyState.wrongAnswer:
        return Icons.sentiment_neutral;
      case BuddyState.correctAnswer:
        return Icons.sentiment_very_satisfied;
    }
  }

  Color _getColor() {
    switch (state) {
      case BuddyState.idle:
        return AppColors.primary;
      case BuddyState.loadingAudio:
        return AppColors.secondary;
      case BuddyState.playingAudio:
        return AppColors.primary;
      case BuddyState.audioFailed:
        return AppColors.error;
      case BuddyState.quizVisible:
        return AppColors.primary;
      case BuddyState.wrongAnswer:
        return Colors.orange;
      case BuddyState.correctAnswer:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getColor().withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Icon(
          _getIcon(),
          size: 72,
          color: _getColor(),
        ),
      ),
    );
  }
}
