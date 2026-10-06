import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'mobile_views.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HananoriApp());
}

class FadeTransitionBuilder extends PageTransitionsBuilder {
  const FadeTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      ),
      child: child,
    );
  }
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class HananoriApp extends StatelessWidget {
  const HananoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Hananori Konveksi',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.black,
            scaffoldBackgroundColor: Colors.white,
            fontFamily: 'Satoshi',
            appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
            pageTransitionsTheme: const PageTransitionsTheme(builders: { TargetPlatform.android: FadeTransitionBuilder(), TargetPlatform.iOS: FadeTransitionBuilder(), TargetPlatform.macOS: FadeTransitionBuilder(), TargetPlatform.windows: FadeTransitionBuilder()}),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.amber,
            scaffoldBackgroundColor: const Color(0xFF0F0F0F), // Premium dark background
            fontFamily: 'Satoshi',
            appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1E1E1E), foregroundColor: Colors.white, elevation: 0),
            pageTransitionsTheme: const PageTransitionsTheme(builders: { TargetPlatform.android: FadeTransitionBuilder(), TargetPlatform.iOS: FadeTransitionBuilder(), TargetPlatform.macOS: FadeTransitionBuilder(), TargetPlatform.windows: FadeTransitionBuilder()}),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.white10,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}