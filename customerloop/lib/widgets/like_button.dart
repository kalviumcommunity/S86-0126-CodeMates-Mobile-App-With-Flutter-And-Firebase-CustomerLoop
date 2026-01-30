import 'package:flutter/material.dart';

/// LikeButton - A reusable stateful widget for like/favorite functionality
///
/// This custom widget manages its own state for liked/unliked status
/// Features:
/// - Toggle animation
/// - Color change on state
/// - Callback function support
/// - Can be used for favorites, likes, bookmarks, etc.
class LikeButton extends StatefulWidget {
  final bool initialLiked;
  final Function(bool)? onChanged;
  final Color likedColor;
  final Color unlikedColor;
  final double size;

  const LikeButton({
    super.key,
    this.initialLiked = false,
    this.onChanged,
    this.likedColor = Colors.red,
    this.unlikedColor = Colors.grey,
    this.size = 28,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late bool _isLiked;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.initialLiked;

    // Initialize animation controller for scale effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Trigger animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Call callback if provided
    if (widget.onChanged != null) {
      widget.onChanged!(_isLiked);
    }

    // Debug logging
    debugPrint('❤️ Like button toggled: $_isLiked');
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          _isLiked ? Icons.favorite : Icons.favorite_border,
          color: _isLiked ? widget.likedColor : widget.unlikedColor,
        ),
        iconSize: widget.size,
        onPressed: _toggleLike,
        tooltip: _isLiked ? 'Unlike' : 'Like',
      ),
    );
  }
}
