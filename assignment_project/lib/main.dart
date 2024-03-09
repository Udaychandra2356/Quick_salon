import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Top 10 Songs',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TopSongsPage(),
    );
  }
}

class TopSongsPage extends StatefulWidget {
  const TopSongsPage({super.key});

  @override
  _TopSongsPageState createState() => _TopSongsPageState();
}

class _TopSongsPageState extends State<TopSongsPage> {
  List<dynamic> _songs = [];

  @override
  void initState() {
    super.initState();
    _fetchTopSongs();
  }

  Future<void> _fetchTopSongs() async {
    final response = await http.get(
        Uri.parse('https://itunes.apple.com/us/rss/topsongs/limit=10/json'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _songs = data['feed']['entry'];
      });
    } else {
      throw Exception('Failed to load top songs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top 10 Songs'),
      ),
      body: ListView.builder(
        itemCount: _songs.length,
        itemBuilder: (context, index) {
          final song = _songs[index];
          final String title = song['title']['label'];
          final String albumName = song['im:collection']['im:name']['label'];
          final String imageUrl = song['im:image'][2]['label'];
          return ListTile(
            leading: Image.network(imageUrl),
            title: Text(title),
            subtitle: Text(albumName),
          );
        },
      ),
    );
  }
}
