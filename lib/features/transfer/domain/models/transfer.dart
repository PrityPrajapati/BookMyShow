import 'package:freezed_annotation/freezed_annotation.dart';

part 'transfer.freezed.dart';
part 'transfer.g.dart';

enum TransferStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Transfer with _$Transfer {
  const factory Transfer({
    required String id,
    required String bookingId,
    required String ticketId,
    required String fromUserId,
    String? fromUserName,
    required String toUserPhone,
    String? toUserEmail,
    @Default(TransferStatus.pending) TransferStatus status,
    required DateTime initiatedAt,
    DateTime? completedAt,
    String? note,
  }) = _Transfer;

  factory Transfer.fromJson(Map<String, dynamic> json) =>
      _$TransferFromJson(json);
}
