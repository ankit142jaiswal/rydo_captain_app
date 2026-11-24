import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _taglineFadeAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scaleAnim = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _taglineFadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Keep splash visible for at least 2.6 s so the animation is fully enjoyed
    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.checkAuthStatus();

    if (!mounted) return;
    if (authService.isAuthenticated) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.brandGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = constraints.maxWidth * 0.32;
              final clampedLogo = logoSize.clamp(96.0, 160.0);

              return Column(
                children: [
                  // ── Top decorative accent ───────────────────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      width: size.width * 0.5,
                      height: size.width * 0.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.04),
                      ),
                      transform: Matrix4.translationValues(
                          size.width * 0.18, -size.width * 0.18, 0),
                    ),
                  ),

                  // ── Centre content ──────────────────────────────────────
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo card
                              FadeTransition(
                                opacity: _fadeAnim,
                                child: ScaleTransition(
                                  scale: _scaleAnim,
                                  child: Container(
                                    width: clampedLogo,
                                    height: clampedLogo,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                          clampedLogo * 0.24),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.22),
                                          blurRadius: 32,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: AppColors.dark.withOpacity(0.3),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset(
                                        'assets/images/rydo_captain_logo.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: clampedLogo * 0.28),

                              // App name
                              FadeTransition(
                                opacity: _fadeAnim,
                                child: Text(
                                  'Rydo Captain',
                                  style: TextStyle(
                                    fontSize: (constraints.maxWidth * 0.078)
                                        .clamp(26.0, 38.0),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.6,
                                    height: 1.1,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Tagline
                              FadeTransition(
                                opacity: _taglineFadeAnim,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Drive.  Earn.  Grow.',
                                    style: TextStyle(
                                      fontSize:
                                          (constraints.maxWidth * 0.038)
                                              .clamp(13.0, 18.0),
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.92),
                                      letterSpacing: 1.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  // ── Bottom loading indicator ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(bottom: 48),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.85),
                            ),
                            strokeWidth: 2.5,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Starting your journey…',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
