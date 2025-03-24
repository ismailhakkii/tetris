import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_cell.dart';
import '../viewmodels/game_viewmodel.dart';

class GridCell extends ConsumerStatefulWidget {
  final GameCell cell;
  final VoidCallback onTap;
  
  const GridCell({
    Key? key,
    required this.cell,
    required this.onTap,
  }) : super(key: key);

  @override
  ConsumerState<GridCell> createState() => _GridCellState();
}

class _GridCellState extends ConsumerState<GridCell> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _shakeAnimation;
  final GlobalKey _cellKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0.05, 0)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0.05, 0), end: const Offset(-0.05, 0)),
        weight: 2,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(-0.05, 0), end: Offset.zero),
        weight: 1,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Pozisyonu kaydet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveCellPosition();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final vm = ref.read(gameViewModelProvider);
    
    // Hücre değeri değiştiğinde animasyon tetikle
    if (oldWidget.cell.value != widget.cell.value && widget.cell.value != null) {
      _controller.reset();
      _controller.forward().then((_) => _controller.reverse());
    }
    
    // Geçersiz hamle animasyonu
    if (vm.lastInvalidRow == widget.cell.row && 
        vm.lastInvalidCol == widget.cell.col && 
        vm.isShakingCell) {
      _playShakeAnimation();
    }
  }
  
  void _playShakeAnimation() {
    _controller.reset();
    _controller.repeat(period: const Duration(milliseconds: 100), reverse: true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.stop();
        _controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Tıklama animasyonu
        if (!widget.cell.isFixed) {
          _controller.reset();
          _controller.forward().then((_) => _controller.reverse());
        }
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Geçersiz hamle için titreşim, diğer durumlarda ölçeklendirme
          final vm = ref.read(gameViewModelProvider);
          final isInvalidCell = vm.lastInvalidRow == widget.cell.row && 
                              vm.lastInvalidCol == widget.cell.col;
          
          if (isInvalidCell && vm.isShakingCell) {
            return SlideTransition(
              position: _shakeAnimation,
              child: child,
            );
          } else {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          }
        },
        child: Container(
          key: _cellKey,
          decoration: BoxDecoration(
            color: widget.cell.backgroundColor,
            border: Border(
              right: BorderSide(
                width: (widget.cell.col + 1) % 3 == 0 ? 2.0 : 1.0,
                color: Colors.black,
              ),
              bottom: BorderSide(
                width: (widget.cell.row + 1) % 3 == 0 ? 2.0 : 1.0,
                color: Colors.black,
              ),
            ),
          ),
          child: Center(
            child: widget.cell.value != null
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '${widget.cell.value}',
                      key: ValueKey<int?>(widget.cell.value),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: widget.cell.isFixed ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
  
  // Hücre pozisyonunu ViewModel'de kaydet (tamamlama animasyonları için)
  void _saveCellPosition() {
    try {
      final RenderBox? renderBox = _cellKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final vm = ref.read(gameViewModelProvider);
        vm.setCellOffset(widget.cell.row, widget.cell.col, position);
      }
    } catch (e) {
      // Pozisyon kaydetme hatası
    }
  }
}