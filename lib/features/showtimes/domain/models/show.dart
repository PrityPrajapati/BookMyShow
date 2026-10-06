import 'package:freezed_annotation/freezed_annotation.dart';

part 'show.freezed.dart';
part 'show.g.dart';

enum ShowFormat {
  @JsonValue('2D')
  twoD,
  @JsonValue('3D')
  threeD,
  @JsonValue('IMAX2D')
  imax2D,
  @JsonValue('IMAX3D')
  imax3D,
  @JsonValue('4DX')
  fourDX,
}

extension ShowFormatX on ShowFormat {
  String get label {
    switch (this) {
      case ShowFormat.twoD:
        return '2D';
      case ShowFormat.threeD:
        return '3D';
      case ShowFormat.imax2D:
        return 'IMAX 2D';
      case ShowFormat.imax3D:
        return 'IMAX 3D';
      case ShowFormat.fourDX:
        return '4DX';
    }
  }
}

@freezed
class Show with _$Show {
  const factory Show({
    required String id,
    required String eventId,
    required String venueId,
    required String screenId,
    required String screenName,
    required DateTime startTime,
    DateTime? endTime,
    required ShowFormat format,
    @Default('Hindi') String language,
    required Map<String, double> categoryPrices,
    @Default(0.0) double occupancyPct,
    @Default(false) bool isPresale,
    required String seatLayoutId,
  }) = _Show;

  factory Show.fromJson(Map<String, dynamic> json) => _$ShowFromJson(json);
}
