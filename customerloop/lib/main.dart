import 'package:flutter/material.dart';
import 'screens/responsive_home.dart';

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
      _backgroundColor =
          _isWelcomeMode ? Colors.blue.shade50 : Colors.purple.shade50;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive sizing
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;

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
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    AppBar().preferredSize.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: isSmallScreen ? 20 : 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // Icon/Image - responsive size
                      Icon(
                        _isWelcomeMode
                            ? Icons.loop_rounded
                            : Icons.star_rounded,
                        size: isSmallScreen ? 80 : 120,
                        color:
                            _isWelcomeMode
                                ? Colors.blue.shade700
                                : Colors.purple.shade700,
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 30),

                      // Title - responsive font
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _isWelcomeMode
                                ? 'Welcome to Customer Loop!'
                                : 'Build Loyalty, Grow Together!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 24 : 28,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isWelcomeMode
                                      ? Colors.blue.shade900
                                      : Colors.purple.shade900,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 10 : 15),

                      // Subtitle
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                        ),
                        child: Text(
                          _isWelcomeMode
                              ? 'A simple loyalty management app for small businesses'
                              : 'Track customers, reward loyalty, and grow your business',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 30 : 50),

                      // Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ResponsiveHome(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isWelcomeMode
                                  ? Colors.blue.shade700
                                  : Colors.purple.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 30 : 40,
                            vertical: isSmallScreen ? 12 : 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Text(
                          _isWelcomeMode
                              ? 'Explore Dashboard'
                              : 'View Dashboard',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),

                      // Theme Toggle Button
                      TextButton.icon(
                        onPressed: _toggleTheme,
                        icon: Icon(
                          _isWelcomeMode ? Icons.dark_mode : Icons.light_mode,
                          color:
                              _isWelcomeMode
                                  ? Colors.blue.shade700
                                  : Colors.purple.shade700,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        label: Text(
                          'Toggle Theme',
                          style: TextStyle(
                            color:
                                _isWelcomeMode
                                    ? Colors.blue.shade700
                                    : Colors.purple.shade700,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
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
    );
  }
}
