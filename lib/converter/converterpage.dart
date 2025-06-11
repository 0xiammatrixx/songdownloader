import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

class UploadVideoConverterPage extends StatefulWidget {
  const UploadVideoConverterPage({super.key});

  @override
  State<UploadVideoConverterPage> createState() => _UploadVideoConverterPageState();
}

class _UploadVideoConverterPageState extends State<UploadVideoConverterPage> {
  double progress = 0.0;
  bool isLoading = false;
  final AudioPlayer _player = AudioPlayer();

  Future<void> _pickAndConvertVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result == null || result.files.single.path == null) return;

    final videoFile = File(result.files.single.path!);

    setState(() {
      isLoading = true;
      progress = 0.1;
    });

    final dio = Dio();
    final uri = Uri.parse('http://127.0.0.1:8000/convert-uploaded-video');

    final formData = FormData.fromMap({
      'video_file': await MultipartFile.fromFile(videoFile.path),
    });

    try {
      final response = await dio.postUri(
        uri,
        data: formData,
        options: Options(
          responseType: ResponseType.stream,
          contentType: 'multipart/form-data',
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.mp3';
      final file = File(savePath);
      final sink = file.openWrite();

      final total = int.tryParse(response.headers.map['content-length']?.first ?? '0');
      int received = 0;

      await response.data!.stream.listen(
        (List<int>chunk) {
          received += chunk.length;
          sink.add(chunk);

          if (total != null && total > 0) {
            setState(() {
              progress = received / total;
            });
          }
        },
        onDone: () async {
          await sink.close();
          setState(() {
            isLoading = false;
            progress = 1.0;
          });

          _showSuccessDialog(savePath);
        },
        onError: (e) async {
          await sink.close();
          print("❌ Error: $e");
          setState(() {
            isLoading = false;
            progress = 0.0;
          });
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("❌ Upload failed: $e");
      setState(() {
        isLoading = false;
        progress = 0.0;
      });
    }
  }

  void _showSuccessDialog(String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('✅ Conversion Complete'),
        content: Text('Your MP3 is ready!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _player.play(DeviceFileSource(filePath));
            },
            child: Text('Play'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Share.shareXFiles([XFile(filePath)], text: '🎶 Converted MP3');
            },
            child: Text('Share'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Video to MP3'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? Column(
                      children: [
                        CircularProgressIndicator(value: progress),
                        SizedBox(height: 10),
                        Text('${(progress * 100).toStringAsFixed(0)}%'),
                      ],
                    )
                  : ElevatedButton.icon(
                      icon: Icon(Icons.upload_file),
                      label: Text("Upload Video & Convert"),
                      onPressed: _pickAndConvertVideo,
                    ),
              SizedBox(height: screenHeight * 0.1),
            ],
          ),
        ),
      ),
    );
  }
}
