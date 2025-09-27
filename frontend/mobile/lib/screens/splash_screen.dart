import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/star_field.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _floatAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));
    _floatController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated star field background
          const StarField(),
          
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated rocket logo
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [SpaceTheme.glowShadow],
                          ),
                          child: const Text(
                            '🚀',
                            style: TextStyle(fontSize: 100),
                          ),
                        )
                            .animate()
                            .scale(
                              delay: 300.ms,
                              duration: 800.ms,
                              curve: Curves.elasticOut,
                            )
                            .rotate(
                              delay: 300.ms,
                              duration: 800.ms,
                              begin: -0.5,
                              end: 0,
                            ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // App title with gradient
                  ShaderMask(
                    shaderCallback: (bounds) => SpaceTheme.primaryGradient
                        .createShader(bounds),
                    child: const Text(
                      'KeplerAI',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 20),
                  
                  // Subtitle
                  Text(
                    'Discover the cosmos with AI-powered\nexoplanet detection',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Feature cards
                  _buildFeatureCards()
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 800.ms)
                      .slideY(begin: 0.3, end: 0),
                  
                  const SizedBox(height: 60),
                  
                  // Get started button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: SpaceTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: SpaceTheme.primaryPink.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Let's Go!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('🌟', style: TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms, duration: 800.ms)
                      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1))
                      .shimmer(delay: 2000.ms, duration: 1500.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards() {
    final features = [
      {
        'icon': '🤖',
        'title': 'AI Analysis',
        'description': 'Advanced ML algorithms',
      },
      {
        'icon': '📊',
        'title': 'Detailed Results',
        'description': 'Confidence scores & charts',
      },
      {
        'icon': '🌌',
        'title': 'Space Theme',
        'description': 'Beautiful cosmic UI',
      },
      {
        'icon': '📱',
        'title': 'Cross-Platform',
        'description': 'Mobile & web support',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final feature = features[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  feature['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  feature['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: SpaceTheme.primaryPink,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  feature['description']!,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ).animate(delay: Duration(milliseconds: 1100 + (index * 100)))
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.8, 0.8))
            .slideY(begin: 0.2, end: 0);
      },
    );
  }
}
