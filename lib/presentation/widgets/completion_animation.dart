import 'package:flutter/material.dart';

class CompletionAnimationOverlay extends StatefulWidget {
  final List<Offset> positions;
  final AnimationType type;
  
  const CompletionAnimationOverlay({
    Key? key,
    required this.positions,
    this.type = AnimationType.row,
  }) : super(key: key);

  @override
  State<CompletionAnimationOverlay> createState() => _CompletionAnimationOverlayState();
}

enum AnimationType {
  row,
  column,
  block,
}

class _CompletionAnimationOverlayState extends State<CompletionAnimationOverlay> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInCubic),
      ),
    );
    
    // Animasyonu başlat
    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color animationColor;
    switch (widget.type) {
      case AnimationType.row:
        animationColor = Colors.blue.withOpacity(0.3);
        break;
      case AnimationType.column:
        animationColor = Colors.green.withOpacity(0.3);
        break;
      case AnimationType.block:
        animationColor = Colors.purple.withOpacity(0.3);
        break;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Stack(
            children: widget.positions.map((position) {
              return Positioned(
                left: position.dx - (40 * _scaleAnimation.value - 40) / 2,
                top: position.dy - (40 * _scaleAnimation.value - 40) / 2,
                child: Container(
                  width: 40 * _scaleAnimation.value,
                  height: 40 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    color: animationColor,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: animationColor.withOpacity(0.8),
                        blurRadius: 10 * _scaleAnimation.value,
                        spreadRadius: 2 * _scaleAnimation.value,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

// Tamamlanma animasyonu gösterme yardımcı fonksiyonu
void showCompletionAnimation(
  BuildContext context,
  List<Offset> positions,
  AnimationType type,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration.zero,
    pageBuilder: (context, animation1, animation2) {
      return CompletionAnimationOverlay(
        positions: positions,
        type: type,
      );
    },
  );
}