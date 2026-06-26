import 'package:flutter/material.dart';
import '../providers/story_provider.dart';
import '../theme/app_theme.dart';

class BuddyCharacter extends StatefulWidget {
  final BuddyState state;

  const BuddyCharacter({super.key, required this.state});

  @override
  State<BuddyCharacter> createState() => _BuddyCharacterState();
}

class _BuddyCharacterState extends State<BuddyCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(BuddyCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == BuddyState.correctAnswer) {
      // faster bounce on success
      _controller.duration = const Duration(milliseconds: 400);
    } else if (widget.state == BuddyState.playingAudio) {
      // medium pace while talking
      _controller.duration = const Duration(milliseconds: 800);
    } else {
      // slow breathing for idle/other states
      _controller.duration = const Duration(milliseconds: 1500);
    }
  }

  IconData _getIcon() {
    switch (widget.state) {
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
    switch (widget.state) {
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: _getColor().withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getColor().withValues(alpha: 0.4),
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            _getIcon(),
            size: 72,
            color: _getColor(),
          ),
        ),
      ),
    );
  }
}
