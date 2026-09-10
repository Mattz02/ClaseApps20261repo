import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const scorebatUrl = 'https://www.scorebat.com/video-api/v3/';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scorebat Videos',
      home: const VideoPage(),
    );
  }
}

// A single match from the Scorebat API.
class MatchVideo {
  final String title;
  final String thumbnail;
  final String videoUrl;

  MatchVideo({
    required this.title,
    required this.thumbnail,
    required this.videoUrl,
  });

  factory MatchVideo.fromJson(Map<String, dynamic> json) {
    return MatchVideo(
      title: json['title'],
      thumbnail: json['thumbnail'],
      // videoUrl: json['matchviewUrl'], // the match page, not the video itself
      videoUrl: 'https://www.scorebat.com/embed/v/${json['videos'][0]['id']}/',
    );
  }
}

// Requests the Scorebat API and returns its first match.
Future<MatchVideo> fetchMatch() async {
  final response = await http.get(Uri.parse(scorebatUrl));

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final firstMatch = body['response'][0];
    return MatchVideo.fromJson(firstMatch);
  } else {
    throw Exception('Failed to load match (status ${response.statusCode})');
  }
}

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late Future<MatchVideo> match;

  @override
  void initState() {
    super.initState();
    match = fetchMatch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scorebat Videos')),
      body: Center(
        child: FutureBuilder<MatchVideo>(
          future: match,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            final match = snapshot.data!;
            return Card(
              margin: const EdgeInsets.all(16.0),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => launchUrl(Uri.parse(match.videoUrl)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(match.thumbnail, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.play_circle_outline),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
