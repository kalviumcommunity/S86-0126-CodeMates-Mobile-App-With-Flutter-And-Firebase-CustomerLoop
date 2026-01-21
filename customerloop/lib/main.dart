import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Customer Loop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isWelcomeMode = true;
  Color _backgroundColor = Colors.blue.shade50;

  void _toggleTheme() {
    setState(() {
      _isWelcomeMode = !_isWelcomeMode;
      _backgroundColor = _isWelcomeMode ? Colors.blue.shade50 : Colors.purple.shade50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customer Loop',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: Container(
        color: _backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Icon/Image
              Icon(
                _isWelcomeMode ? Icons.loop_rounded : Icons.star_rounded,
                size: 120,
                color: _isWelcomeMode ? Colors.blue.shade700 : Colors.purple.shade700,
              ),
              const SizedBox(height: 30),
              
              // Title
              Text(
                _isWelcomeMode 
                    ? 'Welcome to Customer Loop!' 
                    : 'Build Loyalty, Grow Together!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _isWelcomeMode ? Colors.blue.shade900 : Colors.purple.shade900,
                ),
              ),
              const SizedBox(height: 15),
              
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _isWelcomeMode
                      ? 'A simple loyalty management app for small businesses'
                      : 'Track customers, reward loyalty, and grow your business',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              
              // Button
              ElevatedButton(
                onPressed: _toggleTheme,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isWelcomeMode ? Colors.blue.shade700 : Colors.purple.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  _isWelcomeMode ? 'Explore Features' : 'Go Back',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
