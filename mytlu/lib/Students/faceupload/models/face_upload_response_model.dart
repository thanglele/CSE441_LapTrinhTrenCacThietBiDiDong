import 'dart:convert';

class FaceUploadResponseModel {
  final String message;
  final int? faceDataId; // ID của bản ghi face_data mới (hoặc đã cập nhật)
  final String uploadStatus; // "verified" hoặc "uploaded"

  FaceUploadResponseModel({
    required this.message,
    this.faceDataId,
    required this.uploadStatus,
  });

  factory FaceUploadResponseModel.fromJson(Map<String, dynamic> json) {
    return FaceUploadResponseModel(
      message: json['message'] as String,
      faceDataId: json['faceDatald'] as int?,
      uploadStatus: json['uploadStatus'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'faceDatald': faceDataId,
      'uploadStatus': uploadStatus,
    };
  }
}