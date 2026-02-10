import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/counter_state.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Using watch to rebuild when state changes
    final counterState = context.watch<CounterState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CounterState>().reset(),
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Button pressed:', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            Text(
              '${counterState.count}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    counterState.count >= 10
                        ? Colors.green
                        : counterState.count >= 5
                        ? Colors.orange
                        : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              counterState.count >= 10
                  ? '🎉 Amazing!'
                  : counterState.count >= 5
                  ? '😊 Great!'
                  : '👍 Keep going!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: () => context.read<CounterState>().decrement(),
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 32),
                FloatingActionButton.extended(
                  heroTag: 'increment',
                  onPressed: () => context.read<CounterState>().increment(),
                  icon: const Icon(Icons.add),
                  label: const Text('Increment'),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This counter state is shared across the entire app. '
                'Go back to see the updated value!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
