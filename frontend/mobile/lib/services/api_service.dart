import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/prediction_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  Future<PredictionResult> makePrediction(PredictionRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/predict'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PredictionResult.fromJson(data['result']);
        } else {
          throw Exception('Prediction failed: ${data['error']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<HistoryItem>> getHistory({String sessionId = 'anonymous'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history?session_id=$sessionId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return (data['history'] as List)
              .map((item) => HistoryItem.fromJson(item))
              .toList();
        } else {
          throw Exception('Failed to fetch history: ${data['error']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<UploadResult> uploadFile(String filePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return UploadResult.fromJson(data);
        } else {
          throw Exception('Upload failed: ${data['error']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  Future<ModelInfo> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/model/info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return ModelInfo.fromJson(data['model_info']);
        } else {
          throw Exception('Failed to get model info: ${data['error']}');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
