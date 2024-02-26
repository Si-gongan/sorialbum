import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

// 이미지 캡션을 가져오는 API의 URL
const String aiServerHost = 'http://54.87.223.235:8000';

class ApiService {
  Future<List<double>> fetchTextEmbedding(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$aiServerHost/text-embedding'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': text
        })
      );
      if (response.statusCode == 200) {
        final String decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        if (responseData is Map<String, dynamic> && responseData.containsKey('embedding')) {
          List<double> embedding = List<double>.from(responseData['embedding']);
          return embedding;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load text embeddings');
      }
    } catch(e) {
      print(e);
      return [];
    }
  }

  Future<List<String>> fetchCaptions(List<File> imageFiles) async {
    try {
      // 모든 이미지 파일을 Base64 인코딩하고 리스트로 묶기
      final base64Images = await Future.wait(imageFiles.map((file) async {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        return base64Image;
      }));

      // HTTP POST 요청으로 모든 이미지 데이터를 한 번에 전송
      final response = await http.post(
        Uri.parse('$aiServerHost/image-caption'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'urls': base64Images, // 이미지 리스트를 전송하는 키를 'urls'로 변경
        }),
      );

      // 응답으로 받은 모든 이미지 캡션을 파싱하여 반환
      if (response.statusCode == 200) {
        final String decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        if (responseData is Map<String, dynamic> && responseData.containsKey('captions')) {
          List<String> captions = List<String>.from(responseData['captions']);
          return captions;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load image captions');
      }
    } catch (e) {
      print(e);
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }

  Future<List<List<double>>> fetchImageEmbeddings(List<File> imageFiles) async {
    try {
      // 모든 이미지 파일을 Base64 인코딩하고 리스트로 묶기
      final base64Images = await Future.wait(imageFiles.map((file) async {
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        return base64Image;
      }));

      // HTTP POST 요청으로 모든 이미지 데이터를 한 번에 전송
      final response = await http.post(
        Uri.parse('$aiServerHost/image-embedding'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          'urls': base64Images, // 이미지 리스트를 전송하는 키를 'urls'로 변경
        }),
      );

      // 응답으로 받은 모든 이미지 캡션을 파싱하여 반환
      if (response.statusCode == 200) {
        final String decodedResponse = utf8.decode(response.bodyBytes);
        final responseData = jsonDecode(decodedResponse);

        if (responseData is Map<String, dynamic> && responseData.containsKey('embeddings')) {
          List<List<double>> embeddings = (responseData['embeddings'] as List).map((e) {
            // 내부 리스트의 각 요소를 double로 변환
            return (e as List).map((value) {
              // JSON에서 가져온 숫자는 int 또는 double일 수 있으므로, toDouble()를 사용하여 double로 변환
              return (value is int) ? value.toDouble() : value as double;
            }).toList();
          }).toList();
          return embeddings;
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to load image embeddings');
      }
    } catch (e) {
      print(e);
      return []; // 오류 발생 시 빈 리스트 반환
    }
  }
}