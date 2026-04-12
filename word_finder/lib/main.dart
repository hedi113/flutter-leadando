import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const WordSearchApp());
}

class WordSearchApp extends StatelessWidget {
  const WordSearchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Search',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1D9E75),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const WordSearchScreen(),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

/// Full pool of words. 10 are picked at random each game.
const List<String> kWordPool = [
  // Flutter / Dart UI concepts
  'FLUTTER', 'WIDGET', 'SCAFFOLD', 'MATERIAL', 'THEME',
  'COLUMN', 'ROW', 'STACK', 'PADDING', 'HERO',
  'GESTURE', 'NAVIGATOR', 'ROUTE', 'DIALOG', 'DRAWER',
  'APPBAR', 'INKWELL', 'LISTVIEW', 'GRIDVIEW', 'CARD',
  'CONTAINER', 'ELEVATED', 'OUTLINED', 'FILLED', 'ICON',
  'IMAGE', 'TEXT', 'BUTTON', 'SLIDER', 'SWITCH',
  'CHECKBOX', 'RADIO', 'CHIP', 'BADGE', 'TOOLTIP',
  'SNACKBAR', 'BANNER', 'DIVIDER', 'SPACER', 'FLEXIBLE',
  'EXPANDED', 'ALIGN', 'CENTER', 'WRAP', 'CLIP',
  'OPACITY', 'TRANSFORM', 'ANIMATION', 'TWEEN', 'CURVE',
];

const int kWordsPerGame = 10;

const int kGridSize = 11;

// 8 directions: right, left, down, up, and four diagonals
const List<List<int>> kDirections = [
  [0, 1],
  [0, -1],
  [1, 0],
  [-1, 0],
  [1, 1],
  [1, -1],
  [-1, 1],
  [-1, -1],
];

const List<Color> kFoundColors = [
  Color(0xFF9FE1CB),
  Color(0xFFCECBF6),
  Color(0xFFFAC775),
  Color(0xFFF4C0D1),
  Color(0xFFC0DD97),
  Color(0xFFF5C4B3),
  Color(0xFFB5D4F4),
];

const List<Color> kFoundTextColors = [
  Color(0xFF085041),
  Color(0xFF3C3489),
  Color(0xFF633806),
  Color(0xFF72243E),
  Color(0xFF27500A),
  Color(0xFF993C1D),
  Color(0xFF0C447C),
];

class PlacedWord {
  final String word;
  final List<List<int>> cells; // each item is [row, col]

  const PlacedWord({required this.word, required this.cells});
}

// ─── Puzzle generator ─────────────────────────────────────────────────────────

class PuzzleGenerator {
  final int size;
  final List<String> words;
  final Random _rng = Random();

  late List<List<String>> grid;
  late List<PlacedWord> placed;

  PuzzleGenerator({required this.size, required this.words});

  void generate() {
    grid = List.generate(size, (_) => List.filled(size, ''));
    placed = [];

    final shuffled = [...words]..shuffle(_rng);
    for (final word in shuffled) {
      _placeWord(word);
    }
    _fillRandom();
  }

  bool _placeWord(String word) {
    const maxTries = 200;
    for (int t = 0; t < maxTries; t++) {
      final dir = kDirections[_rng.nextInt(kDirections.length)];
      final r = _rng.nextInt(size);
      final c = _rng.nextInt(size);

      final cells = <List<int>>[];
      bool ok = true;

      for (int i = 0; i < word.length; i++) {
        final nr = r + dir[0] * i;
        final nc = c + dir[1] * i;
        if (nr < 0 || nr >= size || nc < 0 || nc >= size) {
          ok = false;
          break;
        }
        final existing = grid[nr][nc];
        if (existing.isNotEmpty && existing != word[i]) {
          ok = false;
          break;
        }
        cells.add([nr, nc]);
      }

      if (ok) {
        for (int i = 0; i < word.length; i++) {
          grid[cells[i][0]][cells[i][1]] = word[i];
        }
        placed.add(PlacedWord(word: word, cells: cells));
        return true;
      }
    }
    return false;
  }

  void _fillRandom() {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = alphabet[_rng.nextInt(alphabet.length)];
        }
      }
    }
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class WordSearchState extends ChangeNotifier {
  late List<List<String>> grid;
  late List<PlacedWord> placed;
  final Set<String> foundWords = {};
  final Map<String, int> wordColorIndex = {}; // word -> color index
  // Per-cell found color index (null = not found)
  late List<List<int?>> cellColorIndex;

  // Selection state
  List<int>? selectionStart; // [row, col]
  List<List<int>> currentSelection = [];

  bool get isComplete => foundWords.length == placed.length;

  late List<String> activeWords; // the 10 words chosen for this game

  void newGame() {
    // Pick kWordsPerGame unique words at random from the pool
    final pool = [...kWordPool]..shuffle(Random());
    activeWords = pool.take(kWordsPerGame).toList();

    final gen = PuzzleGenerator(size: kGridSize, words: activeWords);
    gen.generate();
    grid = gen.grid;
    placed = gen.placed;
    foundWords.clear();
    wordColorIndex.clear();
    cellColorIndex =
        List.generate(kGridSize, (_) => List.filled(kGridSize, null));
    selectionStart = null;
    currentSelection = [];
    notifyListeners();
  }

  void startSelection(int row, int col) {
    selectionStart = [row, col];
    currentSelection = [
      [row, col]
    ];
    notifyListeners();
  }

  void updateSelection(int row, int col) {
    if (selectionStart == null) return;
    final line = _getLine(selectionStart![0], selectionStart![1], row, col);
    if (line != null) {
      currentSelection = line;
      notifyListeners();
    }
  }

  void endSelection() {
    if (currentSelection.isEmpty) {
      selectionStart = null;
      return;
    }
    final word = currentSelection.map((c) => grid[c[0]][c[1]]).join();
    final wordRev = word.split('').reversed.join();

    PlacedWord? match;
    for (final p in placed) {
      if (!foundWords.contains(p.word) &&
          (p.word == word || p.word == wordRev)) {
        match = p;
        break;
      }
    }

    if (match != null) {
      foundWords.add(match.word);
      final idx = activeWords.indexOf(match.word) % kFoundColors.length;
      wordColorIndex[match.word] = idx;
      for (final cell in match.cells) {
        cellColorIndex[cell[0]][cell[1]] = idx;
      }
    }

    selectionStart = null;
    currentSelection = [];
    notifyListeners();
  }

  bool isCellSelected(int r, int c) =>
      currentSelection.any((cell) => cell[0] == r && cell[1] == c);

  List<List<int>>? _getLine(int r1, int c1, int r2, int c2) {
    final dr = r2 - r1;
    final dc = c2 - c1;
    final len = max(dr.abs(), dc.abs());
    if (len == 0)
      return [
        [r1, c1]
      ];
    // Must be straight or diagonal
    if (dr != 0 && dc != 0 && dr.abs() != dc.abs()) return null;
    final sr = dr == 0 ? 0 : dr ~/ dr.abs();
    final sc = dc == 0 ? 0 : dc ~/ dc.abs();
    return List.generate(len + 1, (i) => [r1 + sr * i, c1 + sc * i]);
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class WordSearchScreen extends StatefulWidget {
  const WordSearchScreen({super.key});

  @override
  State<WordSearchScreen> createState() => _WordSearchScreenState();
}

class _WordSearchScreenState extends State<WordSearchScreen> {
  late WordSearchState _state;

  @override
  void initState() {
    super.initState();
    _state = WordSearchState();
    _state.addListener(_onStateChanged);
    _state.newGame();
  }

  void _onStateChanged() {
    setState(() {});
    if (_state.isComplete) {
      Future.delayed(const Duration(milliseconds: 400), _showCongrats);
    }
  }

  void _showCongrats() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Congratulations!',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'You found all ${_state.placed.length} words!',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _state.newGame();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Play Again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D9E75),
                minimumSize: const Size(160, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _state.removeListener(_onStateChanged);
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final found = _state.foundWords.length;
    final total = _state.placed.length;
    final progress = total > 0 ? found / total : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Word Search',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'New game',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _state.newGame,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$found of $total words found',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1D9E75),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Color(0xFF1D9E75)),
              ),
            ),
            const SizedBox(height: 20),

            // Grid
            Center(child: _buildGrid()),

            const SizedBox(height: 20),

            // Word list
            _buildWordPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onPanStart: (details) => _onPanEvent(details.localPosition, 'start'),
        onPanUpdate: (details) => _onPanEvent(details.localPosition, 'move'),
        onPanEnd: (_) => _state.endSelection(),
        child: LayoutBuilder(builder: (context, constraints) {
          // Make grid fit the available width
          final screenW = MediaQuery.of(context).size.width - 32 - 20;
          final cellSize = min(screenW / kGridSize, 40.0);
          return SizedBox(
            width: cellSize * kGridSize,
            height: cellSize * kGridSize,
            child: Stack(
              children: [
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: kGridSize,
                    childAspectRatio: 1,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: kGridSize * kGridSize,
                  itemBuilder: (_, idx) {
                    final r = idx ~/ kGridSize;
                    final c = idx % kGridSize;
                    return _buildCell(r, c, cellSize);
                  },
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCell(int r, int c, double size) {
    final colorIdx = _state.cellColorIndex[r][c];
    final isSelected = _state.isCellSelected(r, c);
    final isFound = colorIdx != null;

    Color bg = Colors.grey.shade50;
    Color fg = Colors.black87;
    Border? border;

    if (isFound) {
      bg = kFoundColors[colorIdx];
      fg = kFoundTextColors[colorIdx];
    } else if (isSelected) {
      bg = const Color(0xFFB5D4F4);
      fg = const Color(0xFF0C447C);
      border = Border.all(color: const Color(0xFF378ADD), width: 1.5);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: border,
      ),
      child: Center(
        child: Text(
          _state.grid[r][c],
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  void _onPanEvent(Offset localPos, String type) {
    // Find which cell the touch is in
    final screenW = MediaQuery.of(context).size.width - 32 - 20;
    final cellSize = min(screenW / kGridSize, 40.0);
    final paddedPos = localPos - const Offset(10, 10); // account for padding
    final c = (paddedPos.dx / (cellSize + 2)).floor();
    final r = (paddedPos.dy / (cellSize + 2)).floor();
    if (r < 0 || r >= kGridSize || c < 0 || c >= kGridSize) return;

    if (type == 'start') {
      _state.startSelection(r, c);
    } else {
      _state.updateSelection(r, c);
    }
  }

  Widget _buildWordPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIND THESE WORDS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _state.activeWords.map((w) => _buildWordChip(w)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWordChip(String word) {
    final isFound = _state.foundWords.contains(word);
    final idx = _state.wordColorIndex[word];

    final bg = idx != null ? kFoundColors[idx] : Colors.grey.shade100;
    final fg = idx != null ? kFoundTextColors[idx] : Colors.grey.shade700;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFound ? Colors.transparent : Colors.grey.shade300,
        ),
      ),
      child: Text(
        _formatWord(word),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: fg,
          decoration: isFound ? TextDecoration.lineThrough : null,
          decorationColor: fg,
          decorationThickness: 2,
        ),
      ),
    );
  }

  String _formatWord(String w) => w[0] + w.substring(1).toLowerCase();
}
