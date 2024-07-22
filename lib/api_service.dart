import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'https://bibleapi.co';

  Future<List<String>> getBooks() async {
    final response = await http.get(Uri.parse('$baseUrl/books'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((book) => book['name'] as String).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<int> getChapterCount(String bookId) async {
    final response = await http.get(Uri.parse('$baseUrl/books/$bookId'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['chapters'];
    } else {
      throw Exception('Failed to load chapters count');
    }
  }

  Future<List<String>> getVerses(String bookId, int chapter) async {
    final response =
        await http.get(Uri.parse('$baseUrl/books/$bookId/$chapter'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['verses'];
      return data.map((verse) => verse['text'] as String).toList();
    } else {
      throw Exception('Failed to load verses');
    }
  }
}
