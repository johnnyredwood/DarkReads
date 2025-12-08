import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'providers/auth_provider.dart';

class DarkReadsApp extends ConsumerWidget {
  const DarkReadsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return MaterialApp(
      title: 'DarkReads',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 167, 25, 25),
          secondary: const Color.fromARGB(255, 0, 0, 0),
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: currentUser == null ? const WelcomeScreen() : const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}