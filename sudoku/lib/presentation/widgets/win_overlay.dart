// lib/presentation/widgets/win_overlay.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../../domain/entities/game_state.dart';

class WinOverlay extends StatefulWidget {
  final int elapsedSeconds;
  final Difficulty difficulty;

  const WinOverlay({
    super.key,
    required this.elapsedSeconds,
    required this.difficulty,
  });

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<GameProvider>();
    final cs = Theme.of(context).colorScheme;
    final time = provider.formatTime(widget.elapsedSeconds);
    final diff = widget.difficulty.name[0].toUpperCase() +
        widget.difficulty.name.substring(1);

    return FadeTransition(
      opacity: _fade,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: ScaleTransition(
            scale: _scale,
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 56)),
                    const SizedBox(height: 12),
                    Text(
                      'Puzzle Complete!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$diff  •  $time',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => provider.dismissWin(),
                            child: const Text('Review'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              provider.dismissWin();
                              _showNewGame(context, provider);
                            },
                            child: const Text('New Game'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showNewGame(BuildContext context, GameProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Game'),
        content: const Text('Choose difficulty:'),
        actions: Difficulty.values.map((d) {
          final label =
              d.name[0].toUpperCase() + d.name.substring(1);
          return TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.newGame(d);
            },
            child: Text(label),
          );
        }).toList(),
      ),
    );
  }
}
