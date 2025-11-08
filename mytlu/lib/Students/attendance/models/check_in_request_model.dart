// Model cho body request
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

  Map<String, dynamic> toJson() {
    return {
      'classSessionId': classSessionId,
      'qrToken': qrToken,
      'liveSelfieBase64': liveSelfieBase64,
      'clientGpsCoordinates': clientGpsCoordinates,
    };
  }
}