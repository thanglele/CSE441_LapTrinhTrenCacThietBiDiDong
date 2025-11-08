// src/Students/attendance/models/check_in_request_model.dart

class CheckInRequest {
  final int classSessionId;
  final String qrToken;
  final String liveSelfieBase64;
  final String clientGpsCoordinates;

  CheckInRequest({
    required this.classSessionId,
    required this.qrToken,
    required this.liveSelfieBase64,
    required this.clientGpsCoordinates,
  });

  /// Chuyển đổi object thành Map để GỬI (POST) lên Server.
  Map<String, dynamic> toJson() => {
    "classSessionId": classSessionId,
    "qrToken": qrToken,
    "liveSelfieBase64": liveSelfieBase64,
    "clientGpsCoordinates": clientGpsCoordinates,
  };
}