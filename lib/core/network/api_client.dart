import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final _client = http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConstants.baseUrl}$path');

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client
        .get(_uri(path), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  // ---------------------------------------------------------------------------
  // POST JSON
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client
        .post(
          _uri(path),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));
    return _handleResponse(response);
  }

  // ---------------------------------------------------------------------------
  // POST multipart (image upload)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> uploadImage(
    String path,
    File imageFile,
  ) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );
    request.headers['Accept'] = 'application/json';

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------
  Future<void> delete(String path) async {
    final response = await _client
        .delete(_uri(path), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));
    if (response.statusCode != 204 && response.statusCode != 200) {
      _checkStatus(response);
    }
  }

  // ---------------------------------------------------------------------------
  // GET list
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getList(String path) async {
    final response = await _client
        .get(_uri(path), headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 30));
    _checkStatus(response);
    return jsonDecode(response.body) as List<dynamic>;
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  Map<String, dynamic> _handleResponse(http.Response response) {
    _checkStatus(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    String message = 'Request failed';
    try {
      final body = jsonDecode(response.body);
      message = body['detail'] ?? message;
    } catch (_) {}
    throw ApiException(statusCode: response.statusCode, message: message);
  }
}
