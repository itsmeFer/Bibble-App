import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:translator/translator.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class VersesScreen extends StatefulWidget {
  final String book;
  final int chapter;

  VersesScreen({required this.book, required this.chapter});

  @override
  _VersesScreenState createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  late Future<List<String>> _verses;
  GoogleTranslator _translator = GoogleTranslator();

  Future<List<String>> fetchVerses() async {
    final response = await http.get(
      Uri.parse('https://bible-api.com/${widget.book}+${widget.chapter}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<String> verses = [];
      for (var verse in data['verses']) {
        verses.add('${verse['verse']}: ${verse['text']}');
      }
      return verses;
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load verses');
    }
  }

  @override
  void initState() {
    super.initState();
    _verses = fetchVerses();
  }

  Future<List<String>> translateVerses(
      List<String> verses, String languageCode) async {
    if (languageCode == 'en') {
      return verses;
    }
    List<String> translatedVerses = [];
    for (var verse in verses) {
      var translation = await _translator.translate(verse, to: languageCode);
      translatedVerses.add(translation.text);
    }
    return translatedVerses;
  }

  @override
  Widget build(BuildContext context) {
    final languageCode = Provider.of<LanguageProvider>(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} Chapter ${widget.chapter}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<List<String>>(
          future:
              _verses.then((verses) => translateVerses(verses, languageCode)),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No verses found or invalid chapter'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      title: Text(snapshot.data![index],
                          style: TextStyle(fontSize: 16)),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
