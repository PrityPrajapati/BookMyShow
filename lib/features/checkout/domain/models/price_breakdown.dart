import 'package:freezed_annotation/freezed_annotation.dart';

part 'price_breakdown.freezed.dart';
part 'price_breakdown.g.dart';

@freezed
class PriceBreakdown with _$PriceBreakdown {
  const factory PriceBreakdown({
    required double basePrice,
    @Default(0.0) double convenienceFee,
    @Default(0.0) double gst,
    @Default(0.0) double fnbTotal,
    @Default(0.0) double parkingTotal,
    @Default(0.0) double discount,
    required double grandTotal,
    @Default(0.0) double donationAmount,
  }) = _PriceBreakdown;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) =>
      _$PriceBreakdownFromJson(json);
}
