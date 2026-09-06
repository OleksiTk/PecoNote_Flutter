import 'dart:io';

import 'package:dio/dio.dart';

/// POST /transactions/ocr/ — multipart upload of a receipt photo, extracted
/// server-side via OpenAI vision. Returns the raw JSON; never creates a
/// Transaction (caller decides what to do with the extracted fields).
class ReceiptOcrRemoteDataSource {
  const ReceiptOcrRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> extract(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/transactions/ocr/',
      data: formData,
    );
    return response.data ?? const {};
  }
}
