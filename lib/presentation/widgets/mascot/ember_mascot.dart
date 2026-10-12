import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ember_painter.dart';

/// Ember, alive: sways and flickers, blinks at random, watches the habit list
/// (or your finger), and jumps whenever [reactTick] changes or it is tapped.
class EmberMascot extends StatefulWidget {
  final EmberMood mood;
  final double size;

  /// Change this number (e.g. increment it) to make Ember jump.
  final int reactTick;

  final VoidCallback? onTap;

  const EmberMascot({
    super.key,
    required this.mood,
    this.size = 96,
    this.reactTick = 0,
    this.onTap,
  });

  @override
  State<EmberMascot> createState() => _EmberMascotState();
}

class _EmberMascotState extends State<EmberMascot> with TickerProviderStateMixin {
  late final AnimationController _ambient;
  late final AnimationController _blink;
  late final AnimationController _react;
  final _random = math.Random();
  Timer? _blinkTimer;
  Timer? _glanceTimer;
  Timer? _glanceBackTimer;

  /// By default Ember keeps an eye on the habit list below.
  static const _restingLook = Offset(0.15, 0.6);
  Offset _look = _restingLook;
  bool _following = false;

  static Duration _loopFor(EmberMood mood) => switch (mood) {
        EmberMood.celebrating => const Duration(milliseconds: 1400),
        EmberMood.cheering => const Duration(milliseconds: 1800),
        EmberMood.frozen => const Duration(milliseconds: 2000),
        _ => const Duration(milliseconds: 2800),
      };

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(vsync: this, duration: _loopFor(widget.mood))..repeat();
    _blink = AnimationController(vsync: this, duration: const Duration(milliseconds: 160));
    _react = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _scheduleBlink();
    _scheduleGlance();
  }

  @override
  void didUpdateWidget(EmberMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _ambient
        ..duration = _loopFor(widget.mood)
        ..repeat();
    }
    if (old.reactTick != widget.reactTick) _jump();
  }

  void _scheduleBlink() {
    _blinkTimer = Timer(Duration(milliseconds: 2200 + _random.nextInt(3200)), () async {
      if (!mounted) return;
      await _blink.forward();
      if (!mounted) return;
      await _blink.reverse();
      // Sometimes a quick double blink.
      if (mounted && _random.nextDouble() < 0.25) {
        await _blink.forward();
        if (mounted) await _blink.reverse();
      }
      _scheduleBlink();
    });
  }

  /// Every few seconds Ember glances somewhere, then back at your habits.
  void _scheduleGlance() {
    _glanceTimer = Timer(Duration(milliseconds: 3500 + _random.nextInt(4000)), () {
      if (!mounted) return;
      if (!_following) {
        setState(() => _look = Offset(_random.nextDouble() * 2 - 1, _random.nextDouble() * 1.2 - 0.6));
        _glanceBackTimer = Timer(const Duration(milliseconds: 900), () {
          if (mounted && !_following) setState(() => _look = _restingLook);
        });
      }
      _scheduleGlance();
    });
  }

  void _jump() {
    _react.forward(from: 0);
  }

  void _lookAt(Offset local) {
    final centre = Offset(widget.size / 2, widget.size * 0.6);
    final d = (local - centre) / (widget.size / 2);
    setState(() => _look = Offset(d.dx.clamp(-1.0, 1.0), d.dy.clamp(-1.0, 1.0)));
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _glanceTimer?.cancel();
    _glanceBackTimer?.cancel();
    _ambient.dispose();
    _blink.dispose();
    _react.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Ember the mascot',
      button: widget.onTap != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _lookAt(d.localPosition),
        onTap: () {
          HapticFeedback.lightImpact();
          _jump();
          widget.onTap?.call();
        },
        onPanStart: (_) => _following = true,
        onPanUpdate: (d) => _lookAt(d.localPosition),
        onPanEnd: (_) {
          _following = false;
          setState(() => _look = _restingLook);
        },
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: Listenable.merge([_ambient, _blink, _react]),
            builder: (context, _) => CustomPaint(
              painter: EmberPainter(
                mood: widget.mood,
                t: _ambient.value,
                blink: _blink.value,
                look: _look,
                react: Curves.easeOut.transform(_react.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
