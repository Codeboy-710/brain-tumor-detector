import 'dart:async';
import 'package:flutter/material.dart';
import 'pages/detector_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  String loadingText = "Initializing AI Model...";

@override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  _fade = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);

  _controller.repeat(reverse: true);

  _startLoadingSequence();

  Future.delayed(const Duration(seconds: 4), () {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DetectorPage()),
    );
  });
}

  void _startLoadingSequence() {
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => loadingText = "Loading MRI Scanner...");
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() => loadingText = "Analyzing Neural Network...");
    });

    Future.delayed(const Duration(seconds: 3), () {
      setState(() => loadingText = "Preparing Diagnosis Engine...");
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _fade,
              child: Image.asset(
                'assets/logo.png',
                height: 120,
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Brain Tumor AI System",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                loadingText,
                key: ValueKey(loadingText),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 25),

            const SizedBox(
              width: 180,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white12,
                color: Colors.blueAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}