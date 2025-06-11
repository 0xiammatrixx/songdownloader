import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

final AudioPlayer player = AudioPlayer();

Future<void> downloadSong(BuildContext context, String query, {
  required void Function(double) onProgress,
  required void Function(bool) onComplete,
}) async {
  try {
    final dio = Dio();
    final postUri = Uri.parse('http://127.0.0.1:8000/download-by-query');

    // 1. Send POST request to trigger the download on server
    final postResponse = await dio.postUri(
      postUri,
      data: jsonEncode({'query': query}),
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // 2. Prepare path to save
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$query.mp3';
    final file = File(filePath);

    // 3. Download with progress
    final total = int.tryParse(
        postResponse.headers.map['content-length']?.first ?? '0');

    int received = 0;
    final sink = file.openWrite();

    await postResponse.data!.stream.listen(
      (List<int>chunk) {
        received += (chunk.length);
        sink.add(chunk);

        // Print download progress
        if (total != null && total > 0) {
          final progress = received / total;
          onProgress(progress);
        }
      },
      onDone: () async {
        await sink.close();
        onProgress(1.0);
        onComplete(true);
        _showPlayOrShareDialog(context, filePath);
      },
      onError: (e) async {
        await sink.close();
        print("❌ Stream error: $e");
      },
      cancelOnError: true,
    );
  } catch (e) {
    print('❌ Error: $e');
  }
}

void _showPlayOrShareDialog(BuildContext context, String filePath) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Download complete!'),
      content: Text('Do you want to play or share the song?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _playMp3(filePath);
          },
          child: Text('Play'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _shareSong(filePath);
          },
          child: Text('Share'),
        ),
      ],
    ),
  );
}

final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> _playMp3(String filePath) async {
  try {
    await _audioPlayer.play(DeviceFileSource(filePath));
    print('🎵 Playing $filePath');
  } catch (e) {
    print('❌ Error playing audio: $e');
  }
}

void _shareSong(String filePath) {
  Share.shareXFiles(
    [XFile(filePath)],
  );
}

