import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authService.error ?? 'Login failed. Please try again.'),
          backgroundColor: const Color(0xFFD32F2F),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    final screenH = mq.size.height;
    final isSmall = screenH < 680;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      // ── Header gradient band ────────────────────────────
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: isSmall ? 24 : 40,
                          bottom: isSmall ? 32 : 48,
                        ),
                        decoration: const BoxDecoration(
                          gradient: AppColors.darkGradient,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(36),
                            bottomRight: Radius.circular(36),
                          ),
                        ),
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: Column(
                              children: [
                                // Logo
                                Container(
                                  width:
                                      (screenW * 0.26).clamp(80.0, 112.0),
                                  height:
                                      (screenW * 0.26).clamp(80.0, 112.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        (screenW * 0.07).clamp(20.0, 28.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
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

                                SizedBox(height: isSmall ? 14 : 20),

                                Text(
                                  'Rydo Captain',
                                  style: TextStyle(
                                    fontSize:
                                        (screenW * 0.068).clamp(22.0, 32.0),
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Drive. Earn. Grow.',
                                  style: TextStyle(
                                    fontSize:
                                        (screenW * 0.034).clamp(12.0, 15.0),
                                    color: Colors.white.withOpacity(0.80),
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // ── Login card ──────────────────────────────────────
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: (screenW * 0.06).clamp(16.0, 32.0),
                            vertical: isSmall ? 20 : 28,
                          ),
                          child: FadeTransition(
                            opacity: _fadeAnim,
                            child: SlideTransition(
                              position: _slideAnim,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.07),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      (screenW * 0.06).clamp(16.0, 28.0),
                                  vertical: isSmall ? 20 : 28,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // Section heading
                                      Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontSize: (screenW * 0.058)
                                              .clamp(20.0, 26.0),
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Enter your captain credentials to continue',
                                        style: TextStyle(
                                          fontSize: (screenW * 0.032)
                                              .clamp(11.0, 14.0),
                                          color: const Color(0xFF607D8B),
                                        ),
                                      ),

                                      SizedBox(height: isSmall ? 18 : 26),

                                      // Email field
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        decoration: const InputDecoration(
                                          labelText: 'Email address',
                                          hintText: 'captain@example.com',
                                          prefixIcon: Icon(
                                              Icons.email_outlined),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.trim().isEmpty) {
                                            return 'Email is required';
                                          }
                                          if (!v.contains('@') ||
                                              !v.contains('.')) {
                                            return 'Enter a valid email address';
                                          }
                                          return null;
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // Password field
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) =>
                                            _handleLogin(),
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          hintText: '••••••••',
                                          prefixIcon:
                                              const Icon(Icons.lock_outline),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                            tooltip: _obscurePassword
                                                ? 'Show password'
                                                : 'Hide password',
                                          ),
                                        ),
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return 'Password is required';
                                          }
                                          if (v.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                      ),

                                      SizedBox(height: isSmall ? 20 : 28),

                                      // Sign-in button
                                      Consumer<AuthService>(
                                        builder:
                                            (context, authService, child) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            height: 52,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              gradient:
                                                  authService.isLoading
                                                      ? null
                                                      : AppColors.primaryGradient,
                                              color: authService.isLoading
                                                  ? AppColors.outlineVariant
                                                  : null,
                                              boxShadow: authService
                                                      .isLoading
                                                  ? []
                                                  : [
                                                      BoxShadow(
                                                        color: AppColors.primary
                                                            .withOpacity(0.38),
                                                        blurRadius: 14,
                                                        offset: const Offset(
                                                            0, 6),
                                                      ),
                                                    ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: authService
                                                      .isLoading
                                                  ? null
                                                  : _handleLogin,
                                              style:
                                                  ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor:
                                                    Colors.transparent,
                                                shape:
                                                    RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          14),
                                                ),
                                                minimumSize: const Size(
                                                    double.infinity, 52),
                                                padding:
                                                    EdgeInsets.zero,
                                              ),
                                              child: authService.isLoading
                                                  ? const SizedBox(
                                                      width: 22,
                                                      height: 22,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            Colors.white,
                                                        strokeWidth: 2.5,
                                                        strokeCap:
                                                            StrokeCap.round,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Sign In',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: AppColors.onPrimary,
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // Demo credentials hint
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline_rounded,
                                              size: 15,
                                              color: const Color(0xFF607D8B),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Demo: raj.driver@gmail.com / driver123',
                                                style: TextStyle(
                                                  fontSize:
                                                      (screenW * 0.028)
                                                          .clamp(10.0, 12.5),
                                                  color: const Color(
                                                      0xFF607D8B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Sign-up link
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "New captain? ",
                                            style: TextStyle(
                                              fontSize: (screenW * 0.033)
                                                  .clamp(12.0, 14.0),
                                              color: const Color(0xFF607D8B),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () =>
                                                Navigator.pushNamed(
                                                    context, '/signup'),
                                            child: Text(
                                              'Create account',
                                              style: TextStyle(
                                                fontSize: (screenW * 0.033)
                                                    .clamp(12.0, 14.0),
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.dark,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor: AppColors.dark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
