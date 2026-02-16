import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../main.dart';

class RoleResolverScreen extends StatefulWidget {
  const RoleResolverScreen({super.key});

  @override
  State<RoleResolverScreen> createState() => _RoleResolverScreenState();
}

class _RoleResolverScreenState extends State<RoleResolverScreen> {
  final _authService = AuthService();
  String? _error;

  @override
  void initState() {
    super.initState();
    _resolveRole();
  }

  Future<void> _resolveRole() async {
    try {
      final user = _authService.currentUser;
      
      if (user == null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/welcome');
        }
        return;
      }

      final userData = await _authService.getUserData(user.uid);
      
      if (userData == null) {
        throw Exception('User data not found');
      }

      if (!mounted) return;

      if (userData.isOwner()) {
        Navigator.pushReplacementNamed(context, '/owner-dashboard');
      } else if (userData.isCustomer()) {
        Navigator.pushReplacementNamed(context, '/customer-dashboard');
      } else {
        throw Exception('Invalid user role');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          actions: [
            ValueListenableBuilder<ThemeMode>(
              valueListenable: themeNotifier,
              builder: (context, mode, _) {
                return IconButton(
                  icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                  onPressed: () {
                    themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                  },
                );
              },
            ),
          ],
        ),
        body: ErrorDisplayWidget(
          message: _error!,
          onRetry: () {
            setState(() {
              _error = null;
            });
            _resolveRole();
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              return IconButton(
                icon: Icon(mode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
                onPressed: () {
                  themeNotifier.value = mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
        ],
      ),
      body: const LoadingWidget(
        message: 'Loading your dashboard...',
      ),
    );
  }
}
