import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapRequestType { swap, release }
enum SwapRequestStatus { pending, approved, denied, cancelled }

class ShiftSwapRequest {
  final String id;
  final String shiftId;
  final String requesterId;
  final String? proposedReplacementId; // null for release
  final SwapRequestType type;
  final SwapRequestStatus status;
  final String? managerComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShiftSwapRequest({
    required this.id,
    required this.shiftId,
    required this.requesterId,
    this.proposedReplacementId,
    required this.type,
    this.status = SwapRequestStatus.pending,
    this.managerComment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShiftSwapRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ShiftSwapRequest(
      id: doc.id,
      shiftId: data['shiftId'] ?? '',
      requesterId: data['requesterId'] ?? '',
      proposedReplacementId: data['proposedReplacementId'],
      type: _typeFromString(data['type'] as String?),
      status: _statusFromString(data['status'] as String?),
      managerComment: data['managerComment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'shiftId': shiftId,
      'requesterId': requesterId,
      'proposedReplacementId': proposedReplacementId,
      'type': type.name,
      'status': status.name,
      'managerComment': managerComment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static SwapRequestType _typeFromString(String? s) {
    switch (s) {
      case 'release':
        return SwapRequestType.release;
      case 'swap':
      default:
        return SwapRequestType.swap;
    }
  }

  static SwapRequestStatus _statusFromString(String? s) {
    switch (s) {
      case 'approved':
        return SwapRequestStatus.approved;
      case 'denied':
        return SwapRequestStatus.denied;
      case 'cancelled':
        return SwapRequestStatus.cancelled;
      case 'pending':
      default:
        return SwapRequestStatus.pending;
    }
  }
}

