import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đọc Căn Cước Công Dân',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.lele.readnfc/nfc');
  Map<String, String> _cardData = {};
  bool _isLoading = false;
  String _status = 'Đang chờ đọc thẻ...';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    platform.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "onNfcDataReceived":
        if (mounted) {
          setState(() {
            _cardData = Map<String, String>.from(call.arguments);
            _isLoading = false;
            _status = 'Đọc thẻ thành công!';
            _errorMessage = null;
          });
        }
        break;
      case "onNfcError":
        if (mounted) {
          setState(() {
            _isLoading = false;
            _status = 'Lỗi khi đọc thẻ.';
            _errorMessage = call.arguments.toString();
          });
        }
        break;
      case "onNfcDetect":
        if (mounted) {
          setState(() {
            _isLoading = true;
            _status = 'Phát hiện thẻ, đang đọc dữ liệu...';
            _errorMessage = null;
            _cardData = {};
          });
        }
        break;
    }
  }

  Widget _buildInfoCard() {
    if (_cardData.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Vui lòng đưa thẻ CCCD vào mặt sau điện thoại',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final photoBase64 = _cardData['photo'];
    Uint8List? imageBytes;
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(photoBase64);
      } catch (e) {
        imageBytes = null;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          if (imageBytes != null)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.memory(
                  imageBytes,
                  width: 150,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Số CCCD', _cardData['documentNumber']),
                  _buildInfoRow('Họ và tên', _cardData['fullName']),
                  _buildInfoRow('Ngày sinh', _cardData['dateOfBirth']),
                  _buildInfoRow('Giới tính', _cardData['gender']),
                  _buildInfoRow('Quốc tịch', _cardData['nationality']),
                  _buildInfoRow('Dân tộc', _cardData['ethnicity']),
                  _buildInfoRow('Tôn giáo', _cardData['religion']),
                  _buildInfoRow('Quê quán', _cardData['placeOfOrigin']),
                  _buildInfoRow(
                      'Nơi thường trú', _cardData['placeOfResidence']),
                  _buildInfoRow('Ngày cấp', _cardData['dateOfIssue']),
                  _buildInfoRow('Ngày hết hạn', _cardData['dateOfExpiry']),
                  _buildInfoRow('Đặc điểm nhận dạng',
                      _cardData['personalIdentification']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đọc Căn Cước Công Dân'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildInfoCard(),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: _errorMessage != null
                ? Colors.red.shade100
                : Colors.blue.shade50,
            child: Column(
              children: [
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: CircularProgressIndicator(),
                  ),
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _errorMessage != null
                        ? Colors.red.shade900
                        : Colors.blue.shade900,
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
