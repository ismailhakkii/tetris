import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class NumberSelector extends ConsumerWidget {
  final Function(int) onNumberSelected;
  final Function(int) getNumberCount;
  
  const NumberSelector({
    Key? key,
    required this.onNumberSelected,
    required this.getNumberCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Rakam Seçin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeMode == ThemeMode.dark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 9,
              itemBuilder: (context, index) {
                final number = index + 1;
                final count = getNumberCount(number);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 200 + (index * 50)),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: NumberButton(
                      number: number,
                      count: count,
                      themeMode: themeMode,
                      onTap: () => onNumberSelected(number),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NumberButton extends StatefulWidget {
  final int number;
  final int count;
  final ThemeMode themeMode;
  final VoidCallback onTap;
  
  const NumberButton({
    Key? key,
    required this.number,
    required this.count,
    required this.themeMode,
    required this.onTap,
  }) : super(key: key);

  @override
  State<NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<NumberButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.reset();
        _controller.forward().then((_) => {
          _controller.reverse(),
          widget.onTap(),
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            color: widget.themeMode == ThemeMode.dark
              ? (widget.count >= 9 ? Colors.grey[700] : Colors.grey[850])
              : (widget.count >= 9 ? Colors.grey[300] : Colors.white),
            border: Border.all(
              color: widget.themeMode == ThemeMode.dark
                ? Colors.grey[600]!
                : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.themeMode == ThemeMode.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.number}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: widget.themeMode == ThemeMode.dark
                    ? Colors.white
                    : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getCountColor(widget.count, widget.themeMode),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.count}/9',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.count >= 9 
                      ? Colors.white 
                      : (widget.themeMode == ThemeMode.dark ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getCountColor(int count, ThemeMode themeMode) {
    if (themeMode == ThemeMode.dark) {
      if (count >= 9) return Colors.grey;
      if (count >= 7) return Colors.orange[700]!;
      if (count >= 4) return Colors.amber[700]!;
      return Colors.green[700]!;
    } else {
      if (count >= 9) return Colors.grey;
      if (count >= 7) return Colors.orange[200]!;
      if (count >= 4) return Colors.yellow[200]!;
      return Colors.green[200]!;
    }
  }
}