import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:songdownloader/linkwidget/downloadyoutube.dart';

class LinkBarWidget extends StatefulWidget {
  final String platform;

  const LinkBarWidget({super.key, required this.platform});

  @override
  State<LinkBarWidget> createState() => _LinkBarWidgetState();
}

class _LinkBarWidgetState extends State<LinkBarWidget> {
  double downloadProgress = 0.0;
  bool isLoading = false;

  Map<String, String>? metadata;
  bool isDownloaded = false;
  final TextEditingController linkController = TextEditingController();
  String query = "";

  void _processLink() async {
    final link = linkController.text.trim();
    if (link.isEmpty) return;

    try {
      setState(() {
        isLoading = true;
        downloadProgress = 0.05; // fake progress start
      });

      final data = await fetchSongMetadata(link);

      setState(() {
        metadata = data;
        isDownloaded = true;
      });

      print("🔍 Query: ${metadata!['artist']} - ${metadata!['title']}");
      print("🖼️ Thumbnail: ${metadata!['thumbnail']}");
    } catch (e) {
      print("❌ Error processing link: $e");
      setState(() {
        isDownloaded = false;
        metadata = null;
      });
    }
  }

  Future<Map<String, String>> fetchSongMetadata(String url) async {
    final uri = Uri.parse("https://api.song.link/v1-alpha.1/links?url=$url");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final entity = data["entitiesByUniqueId"];
      final firstKey = entity.keys.first;
      final title = entity[firstKey]["title"];
      final artist = entity[firstKey]["artistName"];
      final thumbnail = entity[firstKey]["thumbnailUrl"];

      return {"title": title, "artist": artist, "thumbnail": thumbnail};
    } else {
      throw Exception("Failed to fetch song metadata");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.03),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            width: screenWidth * 0.85,
            child: TextField(
              controller: linkController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 255, 255, 255),
                hintText: 'Input ${widget.platform} song link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.pressed)) {
                  return const Color.fromARGB(255, 166, 165, 165);
                }
                return const Color.fromARGB(255, 0, 0, 0);
              }),
              foregroundColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 255, 255, 255),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            onPressed: _processLink,
            child: Text('Search ${widget.platform} link'),
          ),
          isDownloaded
              ? metadata != null
                    ? Column(
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          metadata != null && metadata!['thumbnail'] != null
                              ? Image.network(
                                  metadata!['thumbnail']!,
                                  width: screenWidth * 0.3,
                                  height: screenHeight * 0.15,
                                  fit: BoxFit.contain,
                                )
                              : SizedBox(),
                          Text(
                            '🎵 ${metadata!['title']} by ${metadata!['artist']}',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.resolveWith<Color>((
                                    Set<WidgetState> states,
                                  ) {
                                    if (states.contains(WidgetState.pressed)) {
                                      return const Color.fromARGB(
                                        255,
                                        166,
                                        165,
                                        165,
                                      );
                                    }
                                    return const Color.fromARGB(255, 0, 0, 0);
                                  }),
                              foregroundColor: WidgetStateProperty.all(
                                const Color.fromARGB(255, 255, 255, 255),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              textStyle: WidgetStateProperty.all(
                                const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                downloadProgress = 0.05;
                              });
                              downloadSong(
                                context,
                                "${metadata!['title']} by ${metadata!['artist']}",
                                onProgress: (progress) {
                                  setState(() {
                                    downloadProgress = progress;
                                  });
                                },
                                onComplete: (success) {
                                  setState(() {
                                    isLoading = false;
                                    downloadProgress = success ? 1.0 : 0.0;
                                  });
                                },
                              );
                            },
                            child: Text('Download'),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          if (isLoading || downloadProgress > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 25.0,
                                vertical: 10.0,
                              ),
                              child: LinearProgressIndicator(
                                value: downloadProgress,
                                backgroundColor: Colors.grey[300],
                                color: Colors.purple,
                                minHeight: 8,
                              ),
                            ),
                        ],
                      )
                    : SizedBox()
              : SizedBox(),
        ],
      ),
    );
  }
}
