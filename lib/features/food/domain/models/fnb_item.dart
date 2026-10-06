import 'package:freezed_annotation/freezed_annotation.dart';

part 'fnb_item.freezed.dart';
part 'fnb_item.g.dart';

@freezed
class FnbItem with _$FnbItem {
  const factory FnbItem({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required double price,
    required String category,
    @Default(true) bool isVeg,
    int? calories,
    @Default(0.0) double rating,
  }) = _FnbItem;

  factory FnbItem.fromJson(Map<String, dynamic> json) =>
      _$FnbItemFromJson(json);
}
