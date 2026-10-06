import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:showscape/features/food/domain/models/fnb_item.dart';

part 'fnb_combo.freezed.dart';
part 'fnb_combo.g.dart';

@freezed
class FnbCombo with _$FnbCombo {
  const FnbCombo._();

  const factory FnbCombo({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    @Default([]) List<FnbItem> items,
    required double comboPrice,
    double? originalPrice,
    @Default(0.0) double savings,
  }) = _FnbCombo;

  /// Computed savings between original item sum / original price and combo price
  double get computedSavings {
    if (savings > 0) return savings;
    if (originalPrice != null && originalPrice! > comboPrice) {
      return originalPrice! - comboPrice;
    }
    final itemsSum = items.fold<double>(0.0, (acc, item) => acc + item.price);
    if (itemsSum > comboPrice) {
      return itemsSum - comboPrice;
    }
    return 0.0;
  }

  factory FnbCombo.fromJson(Map<String, dynamic> json) =>
      _$FnbComboFromJson(json);
}
