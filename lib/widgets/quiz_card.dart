import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/quiz_model.dart';
import '../providers/story_provider.dart';
import '../theme/app_theme.dart';

class QuizCard extends StatefulWidget {
  final QuizModel quiz;

  const QuizCard({super.key, required this.quiz});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void didUpdateWidget(QuizCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final state = context.read<StoryProvider>().state;
    if (state == BuddyState.wrongAnswer) {
      HapticFeedback.mediumImpact();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  double _shakeOffset() {
    final value = _shakeAnimation.value;
    return 8 * (0.5 - (value - 0.5).abs()) * (value < 0.5 ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();
    final isCorrect = provider.state == BuddyState.correctAnswer;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset(), 0),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.08)
              : Colors.white,
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
            Text(
              widget.quiz.question,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 20),
            // Data-driven: renders any number of options from JSON
            ...widget.quiz.options.map(
              (option) => _OptionTile(
                option: option,
                isSelected: provider.selectedOption == option,
                isCorrect: isCorrect && option == widget.quiz.answer,
                isWrong: provider.state == BuddyState.wrongAnswer &&
                    provider.selectedOption == option,
                onTap: isCorrect ? null : () => provider.selectAnswer(option),
              ),
            ),
            if (isCorrect) ...[
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const Text(
                      "🎉 Amazing! You got it!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Pip's gear was Blue!",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.success.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color(0xFFE0D9F0);
    Color bgColor = Colors.white;

    if (isCorrect) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.08);
    } else if (isWrong) {
      borderColor = AppColors.error;
      bgColor = AppColors.error.withValues(alpha: 0.08);
    } else if (isSelected) {
      borderColor = AppColors.primary;
      bgColor = AppColors.primary.withValues(alpha: 0.06);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
                color: isCorrect || isWrong ? borderColor : Colors.transparent,
              ),
              child: isCorrect
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isWrong
                      ? const Icon(Icons.close, size: 14, color: Colors.white)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
