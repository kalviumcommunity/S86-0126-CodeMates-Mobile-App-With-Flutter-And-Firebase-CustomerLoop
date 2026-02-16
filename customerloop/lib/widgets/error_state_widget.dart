import 'package:flutter/material.dart';

/// Reusable Error State Widget
/// Assignment 3.47: Handling Errors, Loaders, and Empty States Gracefully
///
/// Displays an error message with optional retry action
class ErrorStateWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;
  final bool showDetails;
  final String? errorDetails;

  const ErrorStateWidget({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.showDetails = false,
    this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 24),
            Text(
              title ?? 'Oops! Something went wrong',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'We encountered an error while loading data. Please try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (showDetails && errorDetails != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  errorDetails!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network Error Widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'No Internet Connection',
      message:
          'Please check your internet connection and try again. Make sure you\'re connected to WiFi or mobile data.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
    );
  }
}

/// Permission Error Widget
class PermissionErrorWidget extends StatelessWidget {
  final String permissionName;
  final VoidCallback? onRetry;

  const PermissionErrorWidget({
    super.key,
    required this.permissionName,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorStateWidget(
      title: 'Permission Required',
      message:
          'This feature requires $permissionName permission. Please grant the permission and try again.',
      icon: Icons.lock_outline,
      onRetry: onRetry,
    );
  }
}

/// Firebase Error Widget
class FirebaseErrorWidget extends StatelessWidget {
  final String? errorCode;
  final VoidCallback? onRetry;

  const FirebaseErrorWidget({super.key, this.errorCode, this.onRetry});

  @override
  Widget build(BuildContext context) {
    String message = _getFirebaseErrorMessage(errorCode);

    return ErrorStateWidget(
      title: 'Firebase Error',
      message: message,
      icon: Icons.cloud_off,
      onRetry: onRetry,
      showDetails: errorCode != null,
      errorDetails: errorCode != null ? 'Error Code: $errorCode' : null,
    );
  }

  String _getFirebaseErrorMessage(String? code) {
    if (code == null) {
      return 'Unable to connect to Firebase services. Please try again later.';
    }

    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to access this data.';
      case 'unavailable':
        return 'Firebase service is temporarily unavailable. Please try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'unauthenticated':
        return 'You need to be logged in to access this feature.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This data already exists.';
      default:
        return 'An error occurred while communicating with Firebase.';
    }
  }
}

/// Generic API Error Widget
class ApiErrorWidget extends StatelessWidget {
  final int? statusCode;
  final VoidCallback? onRetry;

  const ApiErrorWidget({super.key, this.statusCode, this.onRetry});

  @override
  Widget build(BuildContext context) {
    String message = _getStatusMessage(statusCode);

    return ErrorStateWidget(
      title: 'Request Failed',
      message: message,
      icon: Icons.error_outline,
      onRetry: onRetry,
      showDetails: statusCode != null,
      errorDetails: statusCode != null ? 'Status Code: $statusCode' : null,
    );
  }

  String _getStatusMessage(int? code) {
    if (code == null) {
      return 'Failed to communicate with the server. Please try again.';
    }

    if (code >= 500) {
      return 'Server error. Please try again later.';
    } else if (code >= 400) {
      return 'Bad request. Please check your input and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Inline Error Widget (for forms)
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;

  const InlineErrorWidget({super.key, required this.message, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
