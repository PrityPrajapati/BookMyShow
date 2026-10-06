// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferImpl _$$TransferImplFromJson(Map<String, dynamic> json) =>
    _$TransferImpl(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      ticketId: json['ticketId'] as String,
      fromUserId: json['fromUserId'] as String,
      fromUserName: json['fromUserName'] as String?,
      toUserPhone: json['toUserPhone'] as String,
      toUserEmail: json['toUserEmail'] as String?,
      status: $enumDecodeNullable(_$TransferStatusEnumMap, json['status']) ??
          TransferStatus.pending,
      initiatedAt: DateTime.parse(json['initiatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$TransferImplToJson(_$TransferImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'ticketId': instance.ticketId,
      'fromUserId': instance.fromUserId,
      'fromUserName': instance.fromUserName,
      'toUserPhone': instance.toUserPhone,
      'toUserEmail': instance.toUserEmail,
      'status': _$TransferStatusEnumMap[instance.status]!,
      'initiatedAt': instance.initiatedAt.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'note': instance.note,
    };

const _$TransferStatusEnumMap = {
  TransferStatus.pending: 'pending',
  TransferStatus.accepted: 'accepted',
  TransferStatus.rejected: 'rejected',
  TransferStatus.cancelled: 'cancelled',
};
