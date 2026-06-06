import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chord_provider.dart';
import '../data/chord_progressions.dart';
import '../widgets/chord_diagram.dart';

class ChordScreen extends StatelessWidget {
  const ChordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChordProvider>(
      builder: (context, provider, child) {
        final key = provider.selectedKey;
        final keyNotes = _getKeyNotes(key);
        final isZh = Localizations.localeOf(context).languageCode == 'zh';

        return Column(
          children: [
            // 顶部：调式选择器
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                itemCount: provider.availableKeys.length,
                itemBuilder: (context, index) {
                  final k = provider.availableKeys[index];
                  final isSelected = k == key;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      labelStyle: TextStyle(fontSize: 13),
                      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                      label: Text('$k调'),
                      selected: isSelected,
                      onSelected: (_) => provider.selectKey(k),
                    ),
                  );
                },
              ),
            ),
            // 音名行
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    isZh ? '音阶：' : 'Scale: ',
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    keyNotes.join(' - '),
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // 走向列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: ChordProgressions.progressions.length,
                itemBuilder: (context, index) {
                  final prog = ChordProgressions.progressions[index];
                  return _buildProgressionSection(context, prog, key, provider.chords, isZh);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressionSection(
    BuildContext context,
    ChordProgression prog,
    String key,
    List<dynamic> allChords,
    bool isZh,
  ) {
    final chords = prog.getChords(key, allChords.cast());
    final chordNames = prog.getChordNames(key);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 走向标题行
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  prog.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                prog.nameZh,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                chordNames.join('   '),
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.9),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 和弦图横向滚动
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: chords.asMap().entries.map((entry) {
                final chord = entry.value;
                if (chord == null) {
                  return SizedBox(
                    width: 100,
                    height: 120,
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChordDiagram(chord: chord, size: 58),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  List<String> _getKeyNotes(String key) {
    const allNotes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
    final keyIndex = allNotes.indexOf(key);
    if (keyIndex == -1) return [];
    // 大调音阶：全全半全全全半
    const intervals = [0, 2, 4, 5, 7, 9, 11];
    return intervals.map((i) => allNotes[(keyIndex + i) % 12]).toList();
  }
}
