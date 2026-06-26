import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/story_provider.dart';
import 'screens/story_buddy_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryProvider(),
      child: MaterialApp(
        title: 'AI Story Buddy',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const StoryBuddyScreen(),
      ),
    );
  }
}
