import 'package:flutter/material.dart';

/// Debug Tools Demo Screen
///
/// This screen demonstrates:
/// 1. Hot Reload - Change colors, text, or values and press 'r' to see instant updates
/// 2. Debug Console - Logs are printed using debugPrint for tracking state changes
/// 3. DevTools - Use Widget Inspector to explore the widget tree
class DebugToolsDemoScreen extends StatefulWidget {
  const DebugToolsDemoScreen({super.key});

  @override
  State<DebugToolsDemoScreen> createState() => _DebugToolsDemoScreenState();
}

class _DebugToolsDemoScreenState extends State<DebugToolsDemoScreen> {
  // Counter for demonstrating state management and Hot Reload
  int _counter = 0;

  // Color that can be changed to test Hot Reload
  Color _backgroundColor = Colors.blue;

  // Text that can be modified to see Hot Reload in action
  String _welcomeText = 'Welcome to Hot Reload!';

  // List to track actions for Debug Console demonstration
  List<String> _actionLog = [];

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 DebugToolsDemoScreen initialized');
    debugPrint('Initial counter value: $_counter');
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
      final logMessage = 'Counter incremented to $_counter';
      _actionLog.add(logMessage);

      // Debug Console demonstration
      debugPrint('✅ $logMessage');
      debugPrint('Current timestamp: ${DateTime.now()}');
    });
  }

  void _decrementCounter() {
    setState(() {
      _counter--;
      final logMessage = 'Counter decremented to $_counter';
      _actionLog.add(logMessage);

      debugPrint('⬇️ $logMessage');
    });
  }

  void _resetCounter() {
    setState(() {
      final oldValue = _counter;
      _counter = 0;
      final logMessage = 'Counter reset from $oldValue to 0';
      _actionLog.add(logMessage);

      debugPrint('🔄 $logMessage');
    });
  }

  void _changeBackgroundColor() {
    setState(() {
      // Cycle through different colors
      if (_backgroundColor == Colors.blue) {
        _backgroundColor = Colors.purple;
        debugPrint('🎨 Background color changed to purple');
      } else if (_backgroundColor == Colors.purple) {
        _backgroundColor = Colors.teal;
        debugPrint('🎨 Background color changed to teal');
      } else if (_backgroundColor == Colors.teal) {
        _backgroundColor = Colors.orange;
        debugPrint('🎨 Background color changed to orange');
      } else {
        _backgroundColor = Colors.blue;
        debugPrint('🎨 Background color changed to blue');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔨 Building DebugToolsDemoScreen widget');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Debug Tools Demo'),
        backgroundColor: _backgroundColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor.withOpacity(0.1), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hot Reload Demo Card
              _buildHotReloadCard(),
              const SizedBox(height: 16),

              // Counter Display Card
              _buildCounterCard(),
              const SizedBox(height: 16),

              // Debug Console Info Card
              _buildDebugConsoleCard(),
              const SizedBox(height: 16),

              // DevTools Info Card
              _buildDevToolsCard(),
              const SizedBox(height: 16),

              // Action Log Card
              _buildActionLogCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'increment',
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'decrement',
            onPressed: _decrementCounter,
            tooltip: 'Decrement',
            backgroundColor: Colors.red,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  Widget _buildHotReloadCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.flash_on, color: _backgroundColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  '1. Hot Reload Demo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _backgroundColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _backgroundColor),
              ),
              child: Column(
                children: [
                  Text(
                    _welcomeText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _backgroundColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '💡 Try this: Change the _welcomeText variable in the code above and press "r" (Hot Reload) to see instant updates!',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _changeBackgroundColor,
              icon: const Icon(Icons.palette),
              label: const Text('Change Theme Color'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _backgroundColor,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Instructions:\n'
              '• In VS Code: Press "r" in terminal\n'
              '• In Android Studio: Click ⚡ icon\n'
              '• Changes apply instantly without restart',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Counter Value',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _backgroundColor.withOpacity(0.1),
                border: Border.all(color: _backgroundColor, width: 3),
              ),
              child: Text(
                '$_counter',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _backgroundColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetCounter,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Counter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugConsoleCard() {
    return Card(
      elevation: 4,
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.terminal, color: Colors.green[400], size: 28),
                const SizedBox(width: 8),
                const Text(
                  '2. Debug Console',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[400]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '> Logs are printed to Debug Console',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.green[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '> Click buttons to see debugPrint() in action',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.green[400],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '> Check your IDE\'s Debug Console for output',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: Colors.green[400],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'View debug logs in:\n'
              '• VS Code: Debug Console panel\n'
              '• Android Studio: Logcat or Run tab\n'
              '• Terminal: Appears when running flutter run',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevToolsCard() {
    return Card(
      elevation: 4,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.blue[700], size: 28),
                const SizedBox(width: 8),
                Text(
                  '3. Flutter DevTools',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDevToolsFeature(
              Icons.widgets,
              'Widget Inspector',
              'Explore widget tree & UI structure',
            ),
            _buildDevToolsFeature(
              Icons.speed,
              'Performance',
              'Monitor frame rendering & FPS',
            ),
            _buildDevToolsFeature(
              Icons.memory,
              'Memory',
              'Track memory usage & detect leaks',
            ),
            _buildDevToolsFeature(
              Icons.network_check,
              'Network',
              'Monitor API calls & responses',
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'To open DevTools:\n'
                '• VS Code: Click "Open DevTools" in debug mode\n'
                '• Terminal: flutter pub global run devtools\n'
                '• Press "o" in terminal while app is running',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevToolsFeature(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionLogCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: _backgroundColor, size: 28),
                const SizedBox(width: 8),
                const Text(
                  'Action Log',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child:
                  _actionLog.isEmpty
                      ? const Center(
                        child: Text(
                          'No actions yet. Try the buttons!',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _actionLog.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                            child: Text(
                              '${_actionLog.length - index}. ${_actionLog[_actionLog.length - 1 - index]}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        },
                      ),
            ),
            const SizedBox(height: 8),
            const Text(
              '💡 These logs are also printed to Debug Console',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🛑 DebugToolsDemoScreen disposed');
    super.dispose();
  }
}
