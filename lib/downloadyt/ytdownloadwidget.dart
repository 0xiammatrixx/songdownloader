import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class YouTubeDownloadWidget extends StatefulWidget {
  const YouTubeDownloadWidget({super.key});

  @override
  State<YouTubeDownloadWidget> createState() => _YouTubeDownloadWidgetState();
}

class _YouTubeDownloadWidgetState extends State<YouTubeDownloadWidget> {
  double downloadProgress = 0.0;

  final TextEditingController linkController = TextEditingController();
  bool isDownloaded = false;
  bool isLoading = false;
  String? statusMessage;

  Future<void> _downloadVideo(BuildContext context, String videoUrl) async {
    final dio = Dio();
    final backendUrl = 'http://127.0.0.1:8000/download?video_url=$videoUrl';

    try {
      setState(() {
        isLoading = true;
        downloadProgress = 0.05; // fake progress start
      });

      // Save to temp directory
      final dir = await getTemporaryDirectory();
      final savePath = '${dir.path}/video.mp4';

      // Download from backend
      await dio.download(
        backendUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        isLoading = false;
        isDownloaded = true;
        downloadProgress = 1.0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Download complete")));

      // Share or Save
      await Share.shareXFiles([XFile(savePath)]);
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        isLoading = false;
        downloadProgress = 0.0;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to download video")));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.12),
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
                hintText: 'Input YouTube link 100MB Max Size',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: isLoading
                ? null
                : () => _downloadVideo(context, linkController.text.trim()),
            child: isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Download YouTube Video'),
          ),
          SizedBox(height: screenHeight * 0.02),
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
          if (statusMessage != null)
            Text(
              statusMessage!,
              style: TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
