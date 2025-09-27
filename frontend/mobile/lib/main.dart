import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/history_screen.dart';
import 'services/api_service.dart';
import 'services/prediction_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const KeplerAIApp());
}

class KeplerAIApp extends StatelessWidget {
  const KeplerAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider<PredictionService>(
          create: (context) => PredictionService(
            apiService: Provider.of<ApiService>(context, listen: false),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'KeplerAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: MaterialColor(
            0xFFE91E63,
            <int, Color>{
              50: const Color(0xFFFCE4EC),
              100: const Color(0xFFF8BBD9),
              200: const Color(0xFFF48FB1),
              300: const Color(0xFFF06292),
              400: const Color(0xFFEC407A),
              500: const Color(0xFFE91E63),
              600: const Color(0xFFD81B60),
              700: const Color(0xFFC2185B),
              800: const Color(0xFFAD1457),
              900: const Color(0xFF880E4F),
            },
          ),
          scaffoldBackgroundColor: const Color(0xFF121212),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          cardTheme: CardTheme(
            color: Colors.white.withOpacity(0.05),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: const Color(0xFFE91E63).withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFE91E63).withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: const Color(0xFFE91E63).withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE91E63),
                width: 2,
              ),
            ),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE91E63),
            secondary: Color(0xFFF06292),
            surface: Color(0xFF1E1E1E),
            background: Color(0xFF121212),
            error: Color(0xFFCF6679),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
            onError: Colors.black,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/upload': (context) => const UploadScreen(),
          '/history': (context) => const HistoryScreen(),
        },
      ),
    );
  }
}

// Custom theme extensions for space-themed UI
class SpaceTheme {
  static const Color primaryPink = Color(0xFFE91E63);
  static const Color accentPink = Color(0xFFF06292);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryPink, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static BoxShadow get glowShadow => BoxShadow(
    color: primaryPink.withOpacity(0.3),
    blurRadius: 20,
    spreadRadius: 2,
  );
  
  static TextStyle get neonTextStyle => const TextStyle(
    color: primaryPink,
    shadows: [
      Shadow(
        color: primaryPink,
        blurRadius: 10,
      ),
      Shadow(
        color: primaryPink,
        blurRadius: 20,
      ),
    ],
  );
}
