import 'package:flutter/material.dart';

class RadialFunctionCall {
  final VoidCallback? fun;
  final String? tip;

  RadialFunctionCall(this.fun, this.tip);
}

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool locked;
  final bool flipped;
  final bool inverseLocked;
  final VoidCallback? onTap;
  final bool? quickRadialCall;

  // final VoidCallback? onLongPress;

  final RadialFunctionCall? onCancelPress; // 0–500ms
  final RadialFunctionCall? onActionOne; // 501–1000ms
  final RadialFunctionCall? onActionTwo; // 1001ms+

  const FlipCard({
    super.key,
    required this.front,
    required this.back,
    required this.flipped,
    required this.locked,
    this.inverseLocked = false,
    this.onTap,
    this.onCancelPress,
    this.onActionOne,
    this.onActionTwo,
    this.quickRadialCall,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  AnimationController? _progressController;

  DateTime? _pressStart;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);

    if (widget.flipped) {
      _flipController.value = 1;
    }

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != oldWidget.flipped) {
      if (widget.flipped) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    }
  }

  bool _getQuickRadialCallState(double value, [bool? firstCall = false]) {
    final int secondNumerator = widget.quickRadialCall == true ? 2 : 3;
    final int numerator = (firstCall == true ? 1 : secondNumerator);
    final int denominator = widget.quickRadialCall == true ? 3 : 4;

    return value <= numerator / denominator;
  }

  void _onLongPressStart(LongPressStartDetails _) {
    if (!widget.inverseLocked == !widget.locked) {
      if (!widget.locked) return;
    }

    _pressStart = DateTime.now();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.quickRadialCall == true ? 1000 : 1500),
    );

    _progressController!.forward();

    setState(() {});
  }

  void _onLongPressEnd() {
    if (_progressController == null) {
      _resetProgress();
      return;
    }

    final progress = _progressController!.value;

    if (_getQuickRadialCallState(progress, true)) {
      widget.onCancelPress?.fun?.call();
    } else if (_getQuickRadialCallState(progress)) {
      widget.onActionOne?.fun?.call();
    } else {
      widget.onActionTwo?.fun?.call();
    }

    _pressStart = null;
    _resetProgress();
  }

  void _resetProgress() {
    _progressController?.dispose();
    if (mounted) {
      setState(() {
        _progressController = null;
      });
    } else {
      _progressController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.locked) return;
        widget.onTap?.call();
      },
      onLongPressStart: _onLongPressStart,
      onLongPressUp: _onLongPressEnd,
      onLongPressCancel: _onLongPressEnd,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          AnimatedBuilder(
            animation: _flipAnimation,
            builder: (context, child) {
              final angle = _flipAnimation.value * 3.1416;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(angle),
                child: _flipAnimation.value < 0.5
                    ? widget.back
                    : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1416),
                        child: widget.front,
                      ),
              );
            },
          ),
          if (_progressController != null)
            AnimatedBuilder(
              animation: _progressController!,
              builder: (context, _) {
                final progress = _progressController!.value;
                String? currentTip;
                if (_getQuickRadialCallState(progress, true)) {
                  currentTip = widget.onCancelPress?.tip;
                } else if (_getQuickRadialCallState(progress)) {
                  currentTip = widget.onActionOne?.tip;
                } else {
                  currentTip = widget.onActionTwo?.tip;
                }

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 6,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
                        backgroundColor: Colors.black26,
                      ),
                    ),
                    if (currentTip != null)
                      Positioned(
                        top: -45,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            currentTip,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    _progressController?.dispose();
    super.dispose();
  }
}
