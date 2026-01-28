import 'package:flutter/material.dart';

class DemoMenuScreen extends StatelessWidget {
  const DemoMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Menu'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 16),
            Text(
              'Flutter Learning Demos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Explore core Flutter concepts and widgets',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            _buildDemoCard(
              context,
              title: 'Responsive Layout Demo',
              description:
                  'Learn Container, Row, Column widgets and responsive design',
              icon: Icons.dashboard,
              color: Colors.blue,
              route: '/responsive-layout',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              context,
              title: 'Widget Tree Demo',
              description: 'Understand the widget hierarchy and tree structure',
              icon: Icons.account_tree,
              color: Colors.green,
              route: '/widget-tree-demo',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              context,
              title: 'Stateless vs Stateful',
              description:
                  'Learn the differences between stateless and stateful widgets',
              icon: Icons.category,
              color: Colors.orange,
              route: '/stateless-stateful-demo',
            ),
            const SizedBox(height: 12),
            _buildDemoCard(
              context,
              title: 'Debug Tools Demo',
              description: 'Master Flutter debugging tools and hot reload',
              icon: Icons.bug_report,
              color: Colors.red,
              route: '/debug-demo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          description,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey.shade400,
          size: 16,
        ),
        onTap: () {
          Navigator.pushNamed(context, route);
        },
      ),
    );
  }
}
