import 'package:flutter/material.dart';
import '../../auth/presentation/auth_screen.dart';
import '../../../core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  final List<String> images = [
    'assets/onboarding/1.png',
    'assets/onboarding/2.png',
    'assets/onboarding/3.png',
  ];

  // Set 1 copy (selected)
  final List<String> titles = [
    'Welcome to WellQueue',
    'Find Care Fast',
    'Stay Informed',
  ];

  final List<String> subs = [
    'Find nearby clinics and see live wait times so you can plan care with confidence.',
    'See clinics near you, compare wait times, and pick the best option for your family.',
    'Join a queue, get live updates, and arrive at the right time — no more long waits.',
  ];

  final List<String> ctas = ['Get Started', 'Next', "Let's Go"];

  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final p = (_controller.page ?? _controller.initialPage).round();
      if (p != _page) setState(() => _page = p);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCTA(int index) {
    if (index < images.length - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    } else {
      // mark onboarding as seen
      SharedPreferences.getInstance().then((prefs) => prefs.setBool('seen_onboarding', true));
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: images.length,
            itemBuilder: (context, i) {
              return _OnboardingPage(
                image: images[i],
                title: titles[i],
                subtitle: subs[i],
                cta: ctas[i],
                index: i,
                controller: _controller,
                onCTA: () => _handleCTA(i),
              );
            },
          ),
          // top-left brand
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: const [
                  Icon(Icons.local_hospital, color: AppTheme.primary),
                  SizedBox(width: 8),
                  Text('WellQueue', style: TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final String cta;
  final int index;
  final PageController controller;
  final VoidCallback onCTA;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.index,
    required this.controller,
    required this.onCTA,
  });

  @override
  Widget build(BuildContext context) {
      final screenW = MediaQuery.sizeOf(context).width;
      final isCompact = screenW < 390;

    return Stack(
      children: [
        // full-bleed image with parallax + scale based on page controller
        Positioned.fill(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              double page = controller.hasClients && controller.position.hasContentDimensions
                  ? (controller.page ?? controller.initialPage.toDouble())
                  : controller.initialPage.toDouble();
              final double delta = (page - index);
              final double scale = (1 - delta.abs() * 0.06).clamp(0.92, 1.0);
              final double translateX = delta * 40; // parallax strength

              return Transform.translate(
                offset: Offset(translateX, 0),
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.center,
                  child: child,
                ),
              );
            },
            child: Image.asset(image, fit: BoxFit.cover),
          ),
        ),
        // a subtle dark overlay for legibility
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.18)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: isCompact ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onCTA,
                          child: Text(cta),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (i) {
                      final active = i == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active ? AppTheme.primary : Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
