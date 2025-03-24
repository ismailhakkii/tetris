import 'package:flutter/material.dart';

class ScorePanel extends StatefulWidget {
  final int score;
  final int lives;
  final int multiplier;
  
  const ScorePanel({
    Key? key,
    required this.score,
    required this.lives,
    required this.multiplier,
  }) : super(key: key);

  @override
  State<ScorePanel> createState() => _ScorePanelState();
}

class _ScorePanelState extends State<ScorePanel> with SingleTickerProviderStateMixin {
  late int _oldScore;
  late int _oldLives;
  late int _oldMultiplier;
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  
  @override
  void initState() {
    super.initState();
    _oldScore = widget.score;
    _oldLives = widget.lives;
    _oldMultiplier = widget.multiplier;
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(ScorePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    _oldScore = oldWidget.score;
    _oldLives = oldWidget.lives;
    _oldMultiplier = oldWidget.multiplier;
    
    // Skor değiştiğinde animasyon tetikle
    if (widget.score != oldWidget.score || 
        widget.multiplier != oldWidget.multiplier) {
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final scoreChange = widget.score - _oldScore;
    final livesChange = widget.lives - _oldLives;
    final multiplierChange = widget.multiplier - _oldMultiplier;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skor
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skor',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (scoreChange > 0)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -10 * _scoreAnimation.value),
                          child: Opacity(
                            opacity: 1 - _animationController.value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                '+$scoreChange',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          
          // Çarpan
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Çarpan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: 1.0 + (widget.multiplier / 10)),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: multiplierChange > 0 ? scale : 1.0,
                        child: child,
                      );
                    },
                    child: Text(
                      'x${widget.multiplier}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.multiplier > 1 ? Colors.orange : Colors.black,
                      ),
                    ),
                  ),
                  if (multiplierChange > 0)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, -10 * _scoreAnimation.value),
                          child: Opacity(
                            opacity: 1 - _animationController.value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                '↑',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
          
          // Kalan can
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Kalan Hamle',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 1.0, end: livesChange < 0 ? 1.3 : 1.0),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Text(
                      '${widget.lives}/3',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.lives > 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  if (livesChange < 0)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, 10 * _scoreAnimation.value),
                          child: Opacity(
                            opacity: 1 - _animationController.value,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4.0),
                              child: Text(
                                '$livesChange',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}