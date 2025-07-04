import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_field.dart';
import '../providers/user_provider.dart';
import '../utils/helpers.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'cosmic_background.dart';
import 'cosmic_progress_bar.dart';
import 'animated_success1.dart';
import 'animated_failure.dart';
import 'theatre_curtain.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _progressController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _fadeController.forward();
    _scaleController.forward(); // Ensure scale animation completes

    // Add listeners to update progress bar
    _emailController.addListener(() {
      if (_emailController.text.isNotEmpty && _currentStep < 1) {
        setState(() {
          _currentStep = 1;
          _progressController.forward();
        });
        _scaleController.forward(from: 0.0);
      }
    });
    _passwordController.addListener(() {
      if (_passwordController.text.isNotEmpty && _currentStep < 2) {
        setState(() {
          _currentStep = 2;
          _progressController.forward();
        });
        _scaleController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _login() async {
    if (kDebugMode) {
      print('Login button pressed');
      final emailValid = Helpers.validateEmail(_emailController.text);
      final passwordValid = Helpers.validatePassword(_passwordController.text);
      print('Email validation: $emailValid');
      print('Password validation: $passwordValid');
    }
    if (_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('Form validated, attempting login');
      }
      setState(() {
        _isLoading = true;
        _currentStep = _currentStep < 3 ? 3 : _currentStep;
        _progressController.forward();
      });
      try {
        final user = await FirebaseService().login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        if (kDebugMode) {
          print('Login result: user = ${user != null}');
        }
        if (user != null) {
          Provider.of<UserProvider>(context, listen: false).setUser(user);
          await showDialog(
            context: context,
            builder: (_) => const AnimatedSuccess(message: 'Login Successful!'),
          );
          if (kDebugMode) {
            print('Navigating to HomeScreen');
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                  child: child,
                );
              },
            ),
          );
        } else {
          if (kDebugMode) {
            print('Login failed: Invalid email or password');
          }
          await showDialog(
            context: context,
            builder: (_) => const AnimatedFailure(message: 'Invalid email or password'),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid email or password')),
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('Login error: $e');
        }
        await showDialog(
          context: context,
          builder: (_) => AnimatedFailure(message: 'Error: $e'),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      setState(() => _isLoading = false);
    } else {
      if (kDebugMode) {
        print('Form validation failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const CosmicBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                radius: 1.5,
                center: Alignment.center,
              ),
            ),
          ),
          TheatreCurtain(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36),
                  child: GestureDetector(
                    // Fallback to ensure taps are detected
                    onTap: () {
                      if (kDebugMode) {
                        print('Form tapped');
                      }
                      FocusScope.of(context).unfocus(); // Dismiss keyboard
                    },
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Column(
                                children: [
                                  AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    ),
                                    child: Text(
                                      "Welcome to the Cosmos",
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 28,
                                        color: Colors.white,
                                        shadows: const [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.cyanAccent,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  AnimatedBuilder(
                                    animation: _scaleAnimation,
                                    builder: (context, child) => Transform.scale(
                                      scale: _scaleAnimation.value,
                                      child: child,
                                    ),
                                    child: Text(
                                      "Enter the Companion Connect Galaxy",
                                      style: textTheme.bodyMedium?.copyWith(
                                        fontSize: 16,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            CosmicProgressBar(
                              currentStep: _currentStep,
                              totalSteps: 3,
                              controller: _progressController,
                            ),
                            const SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: CustomTextField(
                                label: 'Email',
                                controller: _emailController,
                                validator: (value) {
                                  final result = Helpers.validateEmail(value);
                                  if (kDebugMode) {
                                    print('Email validator result: $result');
                                  }
                                  return result;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: CustomTextField(
                                label: 'Password',
                                controller: _passwordController,
                                obscureText: true,
                                validator: (value) {
                                  final result = Helpers.validatePassword(value);
                                  if (kDebugMode) {
                                    print('Password validator result: $result');
                                  }
                                  return result;
                                },
                              ),
                            ),
                            const SizedBox(height: 30),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: CustomButton(
                                text: 'Enter Galaxy',
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('Enter Galaxy button tapped');
                                  }
                                  _login();
                                },
                                isLoading: _isLoading,
                              ),
                            ),
                            const SizedBox(height: 30),
                            AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) => Transform.scale(
                                scale: _scaleAnimation.value,
                                child: child,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "New to the Cosmos? ",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (kDebugMode) {
                                        print('Initiate Registration button tapped');
                                      }
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (_, __, ___) => const RegisterScreen(),
                                          transitionsBuilder: (_, animation, __, child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1.0, 0.0),
                                                end: Offset.zero,
                                              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Initiate Registration",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
