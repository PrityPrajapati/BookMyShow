import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket.freezed.dart';
part 'ticket.g.dart';

enum TicketStatus {
  @JsonValue('active')
  active,
  @JsonValue('pendingTransfer')
  pendingTransfer,
  @JsonValue('used')
  used,
  @JsonValue('transferred')
  transferred,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
class Ticket with _$Ticket {
  const factory Ticket({
    required String id,
    required String bookingId,
    required String seatId,
    required String seatNumber,
    required String row,
    required int col,
    required String category,
    required double price,
    required String qrData,
    @Default(TicketStatus.active) TicketStatus status,
  }) = _Ticket;

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
}
