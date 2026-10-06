import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';
import 'package:showscape/features/food/domain/repositories/fnb_repository.dart';

class MockFnbRepository implements FnbRepository {
  List<FnbItem>? _cachedItems;
  List<FnbCombo>? _cachedCombos;

  Future<void> _loadAll() async {
    if (_cachedItems != null && _cachedCombos != null) return;

    final jsonStr = await rootBundle.loadString('assets/mock/fnb.json');
    final raw = jsonDecode(jsonStr) as Map<String, dynamic>;

    final itemsRaw = raw['items'] as List<dynamic>? ?? [];
    final combosRaw = raw['combos'] as List<dynamic>? ?? [];

    _cachedItems = itemsRaw
        .map((e) => FnbItem.fromJson(e as Map<String, dynamic>))
        .toList();
    _cachedCombos = combosRaw
        .map((e) => FnbCombo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<FnbItem>> getMenuItems({String? category, bool? vegOnly}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();

    return _cachedItems!.where((item) {
      if (category != null && item.category != category) return false;
      if (vegOnly == true && !item.isVeg) return false;
      return true;
    }).toList();
  }

  @override
  Future<List<FnbCombo>> getCombos() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();
    return List.unmodifiable(_cachedCombos!);
  }

  @override
  Future<FnbItem?> getItemById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _loadAll();
    try {
      return _cachedItems!.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
