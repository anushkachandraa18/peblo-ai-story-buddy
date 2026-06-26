import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/story_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/buddy_character.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_card.dart';

class StoryBuddyScreen extends StatelessWidget {
  const StoryBuddyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StoryProvider>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.menu, color: AppColors.secondary),
        ),
        title: const Text(
          "AI Story Buddy",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle_outlined,
                color: AppColors.secondary, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Buddy Character
            BuddyCharacter(state: provider.state),
            const SizedBox(height: 20),

            // Story Card
            StoryCard(storyText: provider.storyText),
            const SizedBox(height: 20),

            // Read Me a Story Button / Loading / Error
            _buildAudioSection(provider),

            const SizedBox(height: 20),

            // Quiz — slides in after audio completes
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: (provider.state == BuddyState.quizVisible ||
                      provider.state == BuddyState.wrongAnswer ||
                      provider.state == BuddyState.correctAnswer)
                  ? QuizCard(key: const ValueKey('quiz'), quiz: provider.quiz)
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSection(StoryProvider provider) {
    switch (provider.state) {
      case BuddyState.loadingAudio:
        return const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12),
            Text("Preparing story...",
                style: TextStyle(color: AppColors.primary)),
          ],
        );

      case BuddyState.audioFailed:
        return Column(
          children: [
            const Text(
              "Oops! Pip couldn't speak just now 😢",
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: provider.retryAudio,
                icon: const Icon(Icons.refresh),
                label: const Text("Try Again"),
              ),
            ),
          ],
        );

      case BuddyState.playingAudio:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: null, // disabled while playing
            icon: const Icon(Icons.volume_up),
            label: const Text("Reading story..."),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
          ),
        );

      case BuddyState.quizVisible:
      case BuddyState.wrongAnswer:
      case BuddyState.correctAnswer:
        return const SizedBox.shrink(); // button hidden during quiz

      case BuddyState.idle:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: provider.readStory,
            icon: const Icon(Icons.volume_up),
            label: const Text(
              "Read Me a Story",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
    }
  }
}
