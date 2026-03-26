// lib/presentation/widgets/number_pad.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class NumberPad extends StatelessWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final notesMode = provider.notesMode;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Digits row
        Row(
          children: List.generate(9, (i) {
            final digit = i + 1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                child: _DigitButton(
                  digit: digit,
                  onTap: () => provider.enterDigit(digit),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        // Action row
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.undo_rounded,
                label: 'Undo',
                enabled: provider.state?.canUndo ?? false,
                onTap: () => provider.undo(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ActionButton(
                icon: Icons.redo_rounded,
                label: 'Redo',
                enabled: provider.state?.canRedo ?? false,
                onTap: () => provider.redo(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _ActionButton(
                icon: Icons.backspace_outlined,
                label: 'Erase',
                onTap: () => provider.eraseCell(),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: notesMode
                      ? cs.primary
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => provider.toggleNotesMode(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            color: notesMode ? Colors.white : cs.onSurface,
                            size: 22,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 11,
                              color: notesMode ? Colors.white : cs.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final int digit;
  final VoidCallback onTap;

  const _DigitButton({required this.digit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 52,
          alignment: Alignment.center,
          child: Text(
            '$digit',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = enabled ? cs.onSurface : cs.onSurface.withOpacity(0.35);

    return Material(
      color: cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
