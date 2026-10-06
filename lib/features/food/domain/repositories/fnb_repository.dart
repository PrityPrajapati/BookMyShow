import 'package:showscape/features/food/domain/models/fnb_combo.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';

abstract class FnbRepository {
  /// Fetch all food & beverage menu items
  Future<List<FnbItem>> getMenuItems({String? category, bool? vegOnly});

  /// Fetch combos with computed savings
  Future<List<FnbCombo>> getCombos();

  /// Fetch single item by id
  Future<FnbItem?> getItemById(String id);
}
