import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/tuning_scheme.dart';
import '../models/string_tuning.dart';
import '../providers/tuning_provider.dart';
import '../utils/constants.dart';

class TuningFormScreen extends StatefulWidget {
  const TuningFormScreen({super.key});

  @override
  State<TuningFormScreen> createState() => _TuningFormScreenState();
}

class _TuningFormScreenState extends State<TuningFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameEnController = TextEditingController();
  final _songController = TextEditingController();
  final List<TextEditingController> _noteControllers =
      List.generate(6, (_) => TextEditingController());

  bool _isSaving = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _songController.dispose();
    for (final c in _noteControllers) {
      c.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  /// 根据目标音名自动计算变调夹配置
  List<StringTuning>? _calculateCapoConfig(List<String> targetNotes) {
    const standard = AppConstants.standardTuning;
    const allNotes = AppConstants.allNotes;

    final result = <StringTuning>[];

    for (int i = 0; i < 6; i++) {
      final targetNote = targetNotes[i];
      final targetIdx = allNotes.indexOf(targetNote);
      if (targetIdx == -1) return null;

      // 优先：自身弦 + 变调夹
      final stdIdx = allNotes.indexOf(standard[i]);
      final selfDiff = (targetIdx - stdIdx + 12) % 12;
      if (selfDiff <= 7) {
        result.add(StringTuning(
          stringNumber: i + 1,
          capoFret: selfDiff,
          referenceString: i + 1,
        ));
        continue;
      }

      // 备选：其他弦 + 变调夹
      bool found = false;
      for (int j = 0; j < 6; j++) {
        if (j == i) continue;
        final refIdx = allNotes.indexOf(standard[j]);
        final diff = (targetIdx - refIdx + 12) % 12;
        if (diff <= 7) {
          result.add(StringTuning(
            stringNumber: i + 1,
            capoFret: diff,
            referenceString: j + 1,
          ));
          found = true;
          break;
        }
      }
      if (!found) return null;
    }

    return result;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // 收集并标准化音名（支持 b/♭ 写法自动转 #，空弦默认标准音）
    const enharmonicMap = {
      'C': 'C', 'C#': 'C#', 'DB': 'C#',
      'D': 'D', 'D#': 'D#', 'EB': 'D#',
      'E': 'E', 'FB': 'E',
      'F': 'F', 'F#': 'F#', 'GB': 'F#',
      'G': 'G', 'G#': 'G#', 'AB': 'G#',
      'A': 'A', 'A#': 'A#', 'BB': 'A#',
      'B': 'B', 'CB': 'B',
    };
    final targetNotes = <String>[];
    for (int i = 0; i < 6; i++) {
      final raw = _noteControllers[i].text.trim();
      // 未填写的弦默认使用标准音
      if (raw.isEmpty) {
        targetNotes.add(AppConstants.standardTuning[i]);
        continue;
      }
      final upper = raw.toUpperCase().replaceAll('♭', 'B').replaceAll('♯', '#');
      final note = enharmonicMap[upper];
      if (note == null) {
        _showError(
          '${i + 1}弦的音名 "${_noteControllers[i].text}" 无效。\n'
          '有效音名：C C# D D# E F F# G G# A A# B\n'
          '也支持 Db Eb Gb Ab Bb 等写法。',
        );
        return;
      }
      targetNotes.add(note);
    }

    // 计算变调夹配置
    final strings = _calculateCapoConfig(targetNotes);
    if (strings == null) {
      _showError(
        '无法用变调夹实现此特调方案。\n\n'
        '目标音名：${targetNotes.join(' ')}\n\n'
        '变调夹最多支持到第7品，部分音高超出了可调范围。\n'
        '请检查各弦音名是否正确。',
      );
      return;
    }

    // 重复检测
    final provider = context.read<TuningProvider>();
    final newName = _nameEnController.text.trim();

    // 1. 名称重复
    final nameDuplicate = provider.tunings.where(
      (t) => t.nameEn.toLowerCase() == newName.toLowerCase(),
    );
    if (nameDuplicate.isNotEmpty) {
      _showError(
        '方案名称 "$newName" 已存在，请使用其他名称。',
      );
      return;
    }

    // 2. 音名配置重复（和已有特调的实际音名一致）
    const allNotes = AppConstants.allNotes;
    const standard = AppConstants.standardTuning;
    for (final tuning in provider.tunings) {
      final existingNotes = tuning.strings.map((s) {
        final refNote = standard[s.referenceString - 1];
        final refIdx = allNotes.indexOf(refNote);
        return allNotes[(refIdx + s.capoFret) % 12];
      }).toList();
      if (_listEquals(existingNotes, targetNotes)) {
        _showError(
          '当前方案与 "${tuning.getName(Localizations.localeOf(context).languageCode)}" 的音名配置完全一致，添加失败。',
        );
        return;
      }
    }

    // 开始保存动画
    setState(() => _isSaving = true);
    _animController.repeat();

    // 模拟短暂处理延迟（让动画展示）
    await Future.delayed(const Duration(milliseconds: 1800));

    final tuning = TuningScheme(
      id: const Uuid().v4(),
      nameZh: _nameEnController.text,
      nameEn: _nameEnController.text,
      descriptionZh: _songController.text,
      descriptionEn: _songController.text,
      isBuiltIn: false,
      isFavorite: false,
      strings: strings,
    );

    if (mounted) {
      context.read<TuningProvider>().addCustomTuning(tuning);
      _animController.stop();

      // 显示成功提示后返回
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: const Text('添加成功'),
          content: Text(
            '方案 "${tuning.nameEn}" 已保存\n'
            '${_buildConfigSummary(strings)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭弹窗
                Navigator.of(context).pop(); // 返回列表
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  String _buildConfigSummary(List<StringTuning> strings) {
    const standard = AppConstants.standardTuning;
    final parts = <String>[];
    for (int i = 0; i < 6; i++) {
      final s = strings[i];
      final note = AppConstants
          .allNotes[(AppConstants.allNotes.indexOf(standard[s.referenceString - 1]) + s.capoFret) % 12];
      if (s.capoFret == 0) {
        parts.add('${i + 1}弦=$note');
      } else {
        parts.add('${i + 1}弦=$note (夹${s.capoFret}品)');
      }
    }
    return parts.join('  ');
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _showError(String message) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 48),
        title: Text(isZh ? '无法添加' : 'Cannot Add'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(isZh ? '添加特调方案' : 'Add Tuning'),
            actions: [
              TextButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(isZh ? '保存' : 'Save'),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 方案名称
                TextFormField(
                  controller: _nameEnController,
                  decoration: InputDecoration(
                    labelText: isZh ? '方案名称' : 'Tuning Name',
                    hintText: isZh ? '如 DADGAD' : 'e.g. DADGAD',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? (isZh ? '请输入方案名称' : 'Please enter name')
                      : null,
                ),
                const SizedBox(height: 12),
                // 代表曲目
                TextFormField(
                  controller: _songController,
                  decoration: InputDecoration(
                    labelText: isZh ? '代表曲目（可选）' : 'Song (optional)',
                    hintText: isZh ? '如 Kashmir' : 'e.g. Kashmir',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.music_note),
                  ),
                ),
                const SizedBox(height: 24),
                // 标准调弦提示
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        isZh
                            ? '标准调弦：${AppConstants.standardTuning.reversed.join(' ')}  (6→1弦)'
                            : 'Standard: ${AppConstants.standardTuning.reversed.join(' ')}  (6→1)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 各弦输入
                Text(
                  isZh ? '输入各弦目标音名' : 'Enter target note for each string',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  isZh
                      ? '输入每根弦调好后的音名，系统自动计算变调夹位置'
                      : 'Enter the tuned note for each string, capo position will be calculated automatically',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(6, (i) => _buildNoteInput(i, isZh)),
                const SizedBox(height: 24),
                // 保存按钮
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isZh ? '保存方案' : 'Save Tuning',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        // 全屏加载动画
        if (_isSaving)
          FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isZh ? '正在计算变调夹位置...' : 'Calculating capo positions...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isZh ? '正在保存方案' : 'Saving tuning scheme',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNoteInput(int index, bool isZh) {
    final stringNum = index + 1;
    final standardNote = AppConstants.standardTuning[index]; // 1弦=E, 6弦=E

    // 字符串顺序是1弦到6弦，显示时反转让用户感觉从6弦到1弦更自然
    // 但保持1弦在上更符合吉他手习惯
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // 弦号标签
          SizedBox(
            width: 48,
            child: Text(
              '$stringNum弦',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          // 标准音提示
          SizedBox(
            width: 40,
            child: Text(
              standardNote,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward,
              size: 16,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
          const SizedBox(width: 8),
          // 音名输入框
          Expanded(
            child: TextFormField(
              controller: _noteControllers[index],
              decoration: InputDecoration(
                hintText: '$standardNote (标准)',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.25),
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              textCapitalization: TextCapitalization.characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              // 允许为空（默认标准音）
            ),
          ),
        ],
      ),
    );
  }
}
