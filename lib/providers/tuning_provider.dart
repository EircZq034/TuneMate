// lib/providers/tuning_provider.dart
import 'package:flutter/material.dart';
import '../models/tuning_scheme.dart';
import '../data/built_in_tunings.dart';
import '../services/database_service.dart';
import '../services/shared_prefs_service.dart';

class TuningProvider extends ChangeNotifier {
  final _db = DatabaseService.instance;
  final _prefs = SharedPrefsService();

  List<TuningScheme> _tunings = [];
  TuningScheme? _selectedTuning;
  List<String> _favoriteIds = [];

  List<TuningScheme> get tunings => _tunings;
  TuningScheme? get selectedTuning => _selectedTuning;

  List<TuningScheme> get favoriteTunings =>
      _tunings.where((t) => _favoriteIds.contains(t.id)).toList();

  List<TuningScheme> get builtInTunings =>
      _tunings.where((t) => t.isBuiltIn).toList();

  List<TuningScheme> get customTunings =>
      _tunings.where((t) => !t.isBuiltIn).toList();

  Future<void> loadTunings() async {
    // 初始化 prefs 服务
    await _prefs.init();

    // 初始化数据库
    await _db.init();

    _tunings = List.from(BuiltInTunings.tunings);

    final customTunings = await _db.getCustomTunings();
    _tunings.addAll(customTunings);

    _favoriteIds = _prefs.getFavoriteIds();

    _tunings = _tunings.map((t) {
      if (_favoriteIds.contains(t.id)) {
        return t.copyWith(isFavorite: true);
      }
      return t;
    }).toList();

    if (_tunings.isNotEmpty) {
      _selectedTuning = _tunings.first;
    }

    notifyListeners();
  }

  void selectTuning(TuningScheme tuning) {
    _selectedTuning = tuning;
    notifyListeners();
  }

  Future<void> toggleFavorite(TuningScheme tuning) async {
    final index = _tunings.indexWhere((t) => t.id == tuning.id);
    if (index == -1) return;

    final newFavorite = !tuning.isFavorite;
    _tunings[index] = tuning.copyWith(isFavorite: newFavorite);

    if (newFavorite) {
      _favoriteIds.add(tuning.id);
    } else {
      _favoriteIds.remove(tuning.id);
    }

    await _prefs.setFavoriteIds(_favoriteIds);
    notifyListeners();
  }

  Future<void> addCustomTuning(TuningScheme tuning) async {
    assert(!tuning.isBuiltIn, '禁止通过此方法添加内置特调');
    await _db.saveCustomTuning(tuning);
    _tunings.add(tuning);
    notifyListeners();
  }

  Future<void> deleteCustomTuning(String id) async {
    final tuning = _tunings.firstWhere((t) => t.id == id);
    assert(!tuning.isBuiltIn, '禁止删除内置特调');
    await _db.deleteCustomTuning(id);
    _tunings.removeWhere((t) => t.id == id);
    if (_selectedTuning?.id == id) {
      _selectedTuning = _tunings.isNotEmpty ? _tunings.first : null;
    }
    notifyListeners();
  }
}
