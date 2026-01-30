import 'package:flutter/material.dart';

/// ToggleViewButton - A reusable stateful widget for view mode switching
///
/// This custom widget manages state for toggling between different view modes
/// Common uses:
/// - Grid/List view toggle
/// - Dark/Light mode
/// - Expanded/Collapsed view
/// - Any binary state toggle
class ToggleViewButton extends StatefulWidget {
  final bool initialValue;
  final IconData firstIcon;
  final IconData secondIcon;
  final String? firstTooltip;
  final String? secondTooltip;
  final Function(bool)? onChanged;
  final Color? activeColor;

  const ToggleViewButton({
    super.key,
    this.initialValue = false,
    this.firstIcon = Icons.view_list,
    this.secondIcon = Icons.grid_view,
    this.firstTooltip = 'List View',
    this.secondTooltip = 'Grid View',
    this.onChanged,
    this.activeColor,
  });

  @override
  State<ToggleViewButton> createState() => _ToggleViewButtonState();
}

class _ToggleViewButtonState extends State<ToggleViewButton>
    with SingleTickerProviderStateMixin {
  late bool _isToggled;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _isToggled = widget.initialValue;

    // Initialize rotation animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // Half rotation (180 degrees)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (_isToggled) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isToggled = !_isToggled;
    });

    if (_isToggled) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    if (widget.onChanged != null) {
      widget.onChanged!(_isToggled);
    }

    debugPrint('🔄 Toggle view changed: $_isToggled');
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? Theme.of(context).primaryColor;

    return RotationTransition(
      turns: _rotationAnimation,
      child: IconButton(
        icon: Icon(
          _isToggled ? widget.secondIcon : widget.firstIcon,
          color: color,
        ),
        onPressed: _toggle,
        tooltip: _isToggled ? widget.secondTooltip : widget.firstTooltip,
      ),
    );
  }
}
