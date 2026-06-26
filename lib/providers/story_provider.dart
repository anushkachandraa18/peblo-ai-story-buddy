import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/quiz_model.dart';

enum BuddyState {
  idle,
  loadingAudio,
  playingAudio,
  audioFailed,
  quizVisible,
  wrongAnswer,
  correctAnswer,
}

class StoryProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  BuddyState _state = BuddyState.idle;
  BuddyState get state => _state;

  final String storyText =
      "Once upon a time, a clever little robot named Pip lost his shiny blue gear in the Whispering Woods...";

  // Data-driven quiz — this would come from your backend in production.
  final QuizModel quiz = QuizModel.fromJson({
    "question": "What colour was Pip the Robot's lost gear?",
    "options": ["Red", "Green", "Blue", "Yellow"],
    "answer": "Blue",
  });

  String? _selectedOption;
  String? get selectedOption => _selectedOption;

  StoryProvider() {
    _flutterTts.setCompletionHandler(() {
      _setState(BuddyState.quizVisible);
    });

    _flutterTts.setErrorHandler((msg) {
      _setState(BuddyState.audioFailed);
    });
  }

  void _setState(BuddyState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> readStory() async {
    _setState(BuddyState.loadingAudio);

    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45); // slower, kid-friendly pace
      await _flutterTts.setPitch(1.1); // slightly higher, friendlier tone

      _setState(BuddyState.playingAudio);

      final result = await _flutterTts.speak(storyText);

      // speak() returns 1 on success kickoff; actual completion
      // is handled by setCompletionHandler above.
      if (result != 1) {
        _setState(BuddyState.audioFailed);
      }
    } catch (e) {
      _setState(BuddyState.audioFailed);
    }
  }

  void retryAudio() {
    readStory();
  }

  void selectAnswer(String option) {
    _selectedOption = option;

    if (quiz.isCorrect(option)) {
      _setState(BuddyState.correctAnswer);
    } else {
      _setState(BuddyState.wrongAnswer);
      // Let them try again after a short shake animation delay
      Future.delayed(const Duration(milliseconds: 600), () {
        if (_state == BuddyState.wrongAnswer) {
          _selectedOption = null;
          _setState(BuddyState.quizVisible);
        }
      });
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
