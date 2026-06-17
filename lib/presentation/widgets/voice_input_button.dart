import 'package:flutter/material.dart';

/// Mic FAB with animated ripple effect when listening.
class VoiceInputButton extends StatefulWidget {
  final bool isListening;
  final VoidCallback onPressed;
  final String? partialText;

  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onPressed,
    this.partialText,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && !oldWidget.isListening) {
      _animController.repeat(reverse: true);
    } else if (!widget.isListening && oldWidget.isListening) {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Partial text preview
        if (widget.isListening && widget.partialText != null && widget.partialText!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              widget.partialText!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

        // Animated mic button
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isListening ? _scaleAnimation.value : 1.0,
              child: child,
            );
          },
          child: FloatingActionButton(
            onPressed: widget.onPressed,
            backgroundColor: widget.isListening
                ? Colors.red
                : theme.colorScheme.primary,
            child: Icon(
              widget.isListening ? Icons.stop : Icons.mic,
              color: Colors.white,
            ),
          ),
        ),

        // Listening indicator text
        if (widget.isListening)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Listening...',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
