import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

/// Countdown timer widget for a cooking step.
/// Parses [duration] strings like "15 Min", "1h 30m", "45 seconds".
class CookingTimer extends StatefulWidget {
  final String duration;
  final VoidCallback? onComplete;

  const CookingTimer({super.key, required this.duration, this.onComplete});

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  Timer? _ticker;
  int _totalSeconds = 0;
  int _remaining = 0;
  bool _running = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = _parseDuration(widget.duration);
    _remaining = _totalSeconds;
  }

  @override
  void didUpdateWidget(CookingTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _ticker?.cancel();
      _totalSeconds = _parseDuration(widget.duration);
      _remaining = _totalSeconds;
      _running = false;
      _done = false;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  int _parseDuration(String text) {
    final lower = text.toLowerCase();
    int total = 0;
    final h = RegExp(r'(\d+)\s*h').firstMatch(lower);
    if (h != null) total += int.parse(h.group(1)!) * 3600;
    final m = RegExp(r'(\d+)\s*m').firstMatch(lower);
    if (m != null) total += int.parse(m.group(1)!) * 60;
    final s = RegExp(r'(\d+)\s*s').firstMatch(lower);
    if (s != null) total += int.parse(s.group(1)!);
    if (total == 0) {
      final digits = RegExp(r'\d+').firstMatch(text);
      if (digits != null) total = int.parse(digits.group(0)!) * 60;
    }
    return total > 0 ? total : 60;
  }

  void _toggle() {
    if (_done) return;
    if (_running) {
      _ticker?.cancel();
      setState(() => _running = false);
    } else {
      if (_remaining <= 0) setState(() => _remaining = _totalSeconds);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 1) {
          _ticker?.cancel();
          setState(() {
            _remaining = 0;
            _running = false;
            _done = true;
          });
          widget.onComplete?.call();
        } else {
          setState(() => _remaining--);
        }
      });
      setState(() => _running = true);
    }
  }

  void _reset() {
    _ticker?.cancel();
    setState(() {
      _remaining = _totalSeconds;
      _running = false;
      _done = false;
    });
  }

  String _format(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        _totalSeconds > 0 ? (_remaining / _totalSeconds).clamp(0.0, 1.0) : 0.0;
    final doneColor = Colors.green.shade600;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _done ? const Color(0xFFEDF7EE) : AppColors.bgMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _done
              ? Colors.green.shade300
              : _running
                  ? AppColors.primary
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Circular progress + play/pause
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3.5,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _done
                          ? doneColor
                          : _running
                              ? AppColors.primary
                              : AppColors.textLight,
                    ),
                  ),
                ),
                if (_done)
                  Icon(Icons.check_circle_rounded, color: doneColor, size: 24)
                else
                  GestureDetector(
                    onTap: _toggle,
                    child: Icon(
                      _running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _done ? 'Done!' : _format(_remaining),
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _done ? doneColor : AppColors.textDark,
                  ),
                ),
                Text(
                  _done ? 'Step complete ✓' : 'of ${widget.duration}',
                  style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          if (!_done)
            GestureDetector(
              onTap: _reset,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.refresh_rounded,
                    color: AppColors.textLight, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}
