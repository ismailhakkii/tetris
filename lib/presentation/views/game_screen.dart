import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';

import '../../domain/game_engine.dart';
import '../../core/theme/theme_provider.dart';
import '../viewmodels/game_viewmodel.dart';
import '../widgets/grid_cell.dart';
import '../widgets/number_selector.dart';
import '../widgets/score_panel.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with SingleTickerProviderStateMixin {
  late AnimationController _gameOverController;
  late Animation<double> _gameOverAnimation;
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    
    // Oyun sonu animasyonları
    _gameOverController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _gameOverAnimation = CurvedAnimation(
      parent: _gameOverController,
      curve: Curves.easeInOut,
    );
    
    // Konfeti kontrolcüsü
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }
  
  @override
  void dispose() {
    _gameOverController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(gameViewModelProvider);
    final size = MediaQuery.of(context).size;
    final gridSize = size.width > size.height - 200 
        ? size.height - 200 
        : size.width;
    
    // Oyun durumu değiştiğinde animasyonları tetikle
    if (vm.isGameOver && !_gameOverController.isAnimating && !_gameOverController.isCompleted) {
      _gameOverController.forward();
    }
    
    if (vm.isGameWon) {
      _confettiController.play();
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Oyunu'),
        actions: [
          // Tema değiştirme butonu
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeProvider);
              return IconButton(
                icon: Icon(
                  themeMode == ThemeMode.dark 
                    ? Icons.light_mode 
                    : Icons.dark_mode,
                ),
                onPressed: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
                tooltip: themeMode == ThemeMode.dark 
                  ? 'Aydınlık Tema' 
                  : 'Karanlık Tema',
              );
            },
          ),
          
          // Zorluk seviyesi menüsü
          PopupMenuButton<GameDifficulty>(
            onSelected: (difficulty) {
              vm.setDifficulty(difficulty);
              _resetAnimations();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: GameDifficulty.easy,
                child: Text('Kolay'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.medium,
                child: Text('Orta'),
              ),
              const PopupMenuItem(
                value: GameDifficulty.hard,
                child: Text('Zor'),
              ),
            ],
          ),
          
          // Yeniden başlatma butonu
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              vm.newGame();
              _resetAnimations();
            },
            tooltip: 'Yeniden Başlat',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ScorePanel(
                score: vm.score,
                lives: vm.remainingLives,
                multiplier: vm.multiplier,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sudoku Grid
                      Container(
                        width: gridSize,
                        height: gridSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withOpacity(0.6)
                              : Colors.black,
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: GridView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 9,
                          ),
                          itemCount: 81,
                          itemBuilder: (context, index) {
                            final row = index ~/ 9;
                            final col = index % 9;
                            final cell = vm.grid[row][col];
                            
                            return GridCell(
                              cell: cell,
                              onTap: () => _showNumberSelector(context, row, col),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Oyun sonu mesajları
          if (vm.isGameOver)
            FadeTransition(
              opacity: _gameOverAnimation,
              child: Center(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(_gameOverAnimation),
                  child: Container(
                    width: size.width * 0.8,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.red[900]!.withOpacity(0.8)
                        : Colors.red[100],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.sentiment_dissatisfied,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Oyun Bitti!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skorunuz: ${vm.score}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            vm.newGame();
                            _resetAnimations();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Yeniden Başlat'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          
          // Konfeti animasyonu (kazanma durumu için)
          if (vm.isGameWon)
            Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    particleDrag: 0.05,
                    emissionFrequency: 0.05,
                    numberOfParticles: 20,
                    gravity: 0.2,
                    colors: const [
                      Colors.green,
                      Colors.blue,
                      Colors.pink,
                      Colors.orange,
                      Colors.purple,
                      Colors.yellow,
                    ],
                  ),
                ),
                Center(
                  child: AnimatedOpacity(
                    opacity: vm.isGameWon ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      width: size.width * 0.8,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.green[900]!.withOpacity(0.8)
                          : Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 64,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tebrikler!',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Skorunuz: ${vm.score}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              vm.newGame();
                              _resetAnimations();
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Yeni Oyun'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  void _showNumberSelector(BuildContext context, int row, int col) {
    final vm = ref.read(gameViewModelProvider);
    
    // Sabit hücre ise seçim yapılamaz
    if (vm.grid[row][col].isFixed || vm.isGameOver || vm.isGameWon) {
      return;
    }
    
    showModalBottomSheet(
      context: context,
      builder: (context) => NumberSelector(
        onNumberSelected: (value) {
          Navigator.pop(context);
          vm.makeMove(row, col, value);
        },
        getNumberCount: vm.getNumberCount,
      ),
    );
  }
  
  void _resetAnimations() {
    _gameOverController.reset();
    _confettiController.stop();
  }
}