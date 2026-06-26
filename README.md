# 🤖 Peblo AI Story Buddy — Flutter Challenge Submission

## Overview
A single-screen Flutter app built for the Peblo internship challenge.
The app reads a short story aloud to a child using text-to-speech,
then presents an interactive, data-driven quiz with celebratory
feedback on correct answers.

---

## 1. Framework Choice: Flutter (Dart)

I chose Flutter because:
- Single codebase targets both Android and iOS — directly relevant
  to Peblo's cross-platform audience
- Flutter's widget-based architecture makes it straightforward to
  build the kind of joyful, animated, child-friendly UI the brief
  described
- Provider is a state management solution I have hands-on experience
  with from my own projects, which meant I could implement a clean
  state machine quickly and confidently
- Flutter's rendering engine runs at 60fps on mid-range Android
  devices (the brief's primary target), making smooth animations
  achievable without reaching for heavy third-party solutions

---

## 2. Audio → Quiz Transition State Management

I modelled the entire app as a single enum-based state machine
rather than using scattered boolean flags (e.g. `isLoading`,
`isPlaying`, `showQuiz`). Scattered booleans create impossible
states — for example, `isLoading = true` AND `showQuiz = true`
simultaneously. A single enum makes illegal states unrepresentable.

```dart
enum BuddyState {
  idle,
  loadingAudio,
  playingAudio,
  audioFailed,
  quizVisible,
  wrongAnswer,
  correctAnswer,
}
```

The transition from audio → quiz is driven by `flutter_tts`'s
native completion callback, not a timer or a guess:

```dart
_flutterTts.setCompletionHandler(() {
  _setState(BuddyState.quizVisible);
});
```

This means the quiz only appears after the audio has genuinely
finished playing — not after an arbitrary delay. The `AnimatedSwitcher`
in the UI then smoothly fades and slides the quiz card in when the
state changes to `quizVisible`.

The Buddy character's icon and color also update reactively based
on the current state — neutral when idle, active when playing,
celebratory on correct answer, sympathetic on wrong answer.

---

## 3. Data-Driven Quiz Renderer

The quiz is never hardcoded in the UI. It is parsed from a JSON
object (simulating a backend response) into a `QuizModel`:

```dart
factory QuizModel.fromJson(Map<String, dynamic> json) {
  return QuizModel(
    question: json['question'] as String,
    options: List<String>.from(json['options'] as List),
    answer: json['answer'] as String,
  );
}
```

The options list uses `List<String>.from()` — meaning it will
correctly render 3, 4, or 5 options without any code changes.
The quiz UI maps over `widget.quiz.options` dynamically:

```dart
...widget.quiz.options.map((option) => _OptionTile(...))
```

To swap in a different question, you change only the JSON object.
No widget code changes required.

---

## 4. Caching Approach

**Current implementation:**
The app uses `flutter_tts` which calls the device's native TTS
engine (Android's `TextToSpeech` API). This requires no network
call and no caching — the engine synthesizes speech locally on
the device. This means:
- Zero latency waiting for audio to download
- Works fully offline
- No cache invalidation concerns
- Lightweight on mid-range Android devices (no audio file stored)

**If using a remote audio API (e.g. ElevenLabs):**
I would cache the generated audio file locally using
`path_provider` to get the app's documents directory, storing
the file keyed by a hash of the story text. On subsequent loads,
I would check if the cached file exists before making a network
request. This avoids redundant API calls and ensures the story
plays even without internet after the first load.

---

## 5. Audio Loading and Failure States

The TTS flow handles three real-world states explicitly:

**Loading:** When the user taps "Read Me a Story", the state
immediately transitions to `loadingAudio`, showing a
`CircularProgressIndicator` and "Preparing story..." text.
The button is replaced so the user cannot tap it twice.

**Playing:** Once `flutter_tts.speak()` returns successfully,
state moves to `playingAudio`. The button shows "Reading
story..." and is disabled to prevent duplicate speech.

**Failure:** Both `setErrorHandler` (native TTS error) and a
try/catch around the `speak()` call transition state to
`audioFailed`. The UI shows a friendly message:
*"Oops! Pip couldn't speak just now 😢"* with a "Try Again"
button that calls `retryAudio()` to restart the flow cleanly.

**Note on offline behavior:** Since `flutter_tts` uses the
device's native engine, the app continues to work without
internet. This is a deliberate advantage of native TTS over
a remote API for a kids' app targeting mid-range Android devices.

---

## 6. Performance Profiling

**What I measured:**
I ran the app in profile mode (`flutter run --profile`) and
observed frame rendering in Flutter DevTools' Performance tab,
focusing on:
- The `AnimatedSwitcher` transition (story → quiz)
- The shake animation on wrong answer
- The buddy icon state change on correct/wrong answer

**What I found and changed:**
- Initially had `context.watch<StoryProvider>()` high up in the
  widget tree, causing the entire screen to rebuild on every state
  change. Moved state reads down to the specific widgets that need
  them, reducing unnecessary rebuilds.
- Used `const` constructors wherever widgets are static
  (e.g. `const StoryCard`, `const SizedBox`) so Flutter skips
  rebuilding them on provider updates.
- Used `ListView` → `SingleChildScrollView + Column` since the
  content is fixed and short — avoids the overhead of a lazy
  list for a screen with only a handful of widgets.

**Result:** Animations ran at a consistent 60fps on a mid-range
Android test device. No janky frames observed during the
audio → quiz transition or the shake animation.

**Optimizations for mid-range Android (3GB RAM):**
- Native TTS means no audio file loaded into memory
- No heavy image assets — buddy character is a Material icon
  (vector, renders at any size, negligible memory)
- `const` widgets reduce widget tree rebuild cost
- `AnimatedSwitcher` uses Flutter's built-in animation system,
  not a third-party animation package

---

## 7. AI Usage & Judgment

I used Claude (Anthropic) as a pair-programming assistant
throughout this challenge.

**Where AI helped:**
- Scaffolding the folder structure and file skeletons
- Suggesting the enum-based state machine pattern instead of
  boolean flags — this was genuinely good advice I adopted
- Explaining `setCompletionHandler` as the right hook for the
  audio → quiz transition
- Fixing Android SDK/NDK/minSdk configuration errors during setup

**One suggestion I rejected:**
Claude initially suggested using `Dio` instead of the `http`
package for API calls. I rejected this because this app makes
no network API calls (native TTS is local), so adding Dio
would be an unnecessary dependency with no benefit. I kept
the dependency list minimal for performance on mid-range devices.

**What didn't work and how I fixed it:**
- `flutter_tts` failed to build initially due to `minSdk = 21`
  being below the plugin's requirement of 24. Fixed by updating
  `android/app/build.gradle.kts` to set `minSdk = 24`,
  `compileSdk = 36`, and `ndkVersion = "27.0.12077973"`.
- VS Code's auto-import wasn't working in my environment, so
  I manually wrote all import statements at the top of each file,
  which also gave me a clearer understanding of the dependency
  relationships between files.

**What I would add with more time:**
- Animated buddy expressions using a full `AnimationController`
  per state (designed but cut for time)
- ElevenLabs API integration with `flutter_tts` as offline fallback
- Confetti package for the success celebration
- Unit tests for `QuizModel.fromJson()` and `StoryProvider`
  state transitions

---

## Project Structure
lib/

├── main.dart

├── models/

│   └── quiz_model.dart

├── providers/

│   └── story_provider.dart

├── screens/

│   └── story_buddy_screen.dart

├── theme/

│   └── app_theme.dart

└── widgets/

├── buddy_character.dart

├── quiz_card.dart

└── story_card.dart

---

## Setup & Run

```bash
flutter pub get
flutter run
```

**Requirements:**
- Flutter SDK 3.x+
- Android SDK 36 / minSdk 24
- NDK 27.0.12077973
- Physical or emulated Android device

---

*Built with Flutter + Dart | State management: Provider |
TTS: flutter_tts (native engine) | Typography: Poppins via
google_fonts*
