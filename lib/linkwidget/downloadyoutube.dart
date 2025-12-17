import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

final AudioPlayer player = AudioPlayer();

Future<String> getDownloadPath(String fileName) async {
  if (Platform.isAndroid) {
    final dir = await getExternalStorageDirectory();
    final musicDir = Directory('${dir!.path}/Music');

    if (!await musicDir.exists()) {
      await musicDir.create(recursive: true);
    }

    return '${musicDir.path}/$fileName.mp3';
  } else {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$fileName.mp3';
  }
}

Future<void> downloadSong(
  BuildContext context,
  String query, {
  required void Function(double) onProgress,
  required void Function(bool) onComplete,
}) async {
  try { 

    final dio = Dio();
    final postUri = Uri.parse('https://songdownloadbackend.onrender.com/download-by-query');

    final postResponse = await dio.postUri(
      postUri,
      data: jsonEncode({'query': query}),
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final filePath = await getDownloadPath(query);
    final file = File(filePath);

    final total = int.tryParse(
      postResponse.headers.map['content-length']?.first ?? '0',
    );

    int received = 0;
    final sink = file.openWrite();

    await postResponse.data!.stream.listen(
      (List<int> chunk) {
        received += (chunk.length);
        sink.add(chunk);

        if (total != null && total > 0) {
          final progress = received / total;
          onProgress(progress);
        }
      },
      onDone: () async {
        await sink.close();
        onProgress(1.0);
        onComplete(true);
        _showPlayOrShareDialog(context, filePath, query);
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

void _showPlayOrShareDialog(BuildContext context, String filePath, String songName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Download complete!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Song saved to:'),
          SizedBox(height: 8),
          Text(
            Platform.isAndroid 
              ? 'Music/SongDownloader/$songName.mp3'
              : 'App Documents',
            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _playMp3(context, filePath);
          },
          child: Text('Play'),
        ),
        if (Platform.isAndroid)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _openFileLocation(context, filePath);
            },
            child: Text('Open Folder'),
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
bool _isPlaying = false;

Future<void> _playMp3(BuildContext context, String filePath) async {
  try {
    // Check if file exists
    final file = File(filePath);
    if (!await file.exists()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Audio file not found')),
      );
      return;
    }

    // Stop if already playing
    if (_isPlaying) {
      await _audioPlayer.stop();
    }

    await _audioPlayer.play(DeviceFileSource(filePath));
    _isPlaying = true;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎵 Now playing...'),
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () async {
            await _audioPlayer.stop();
            _isPlaying = false;
          },
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // Listen for completion
    _audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
    });

    print('🎵 Playing $filePath');
  } catch (e) {
    print('❌ Error playing audio: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error playing audio: $e')),
    );
  }
}

// Android-specific: Open file manager to the download location
Future<void> _openFileLocation(BuildContext context, String filePath) async {
  if (Platform.isAndroid) {
    try {
      // Use share to open "Open with" dialog which includes file managers
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Downloaded song',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File saved to Music/SongDownloader'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error opening location: $e');
    }
  }
}

void _shareSong(String filePath) {
  Share.shareXFiles([XFile(filePath)], text: 'Check out this song!');
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:permission_handler/permission_handler.dart';

// final AudioPlayer player = AudioPlayer();

// Future<String> getDownloadPath(String fileName) async {
//   if (Platform.isAndroid) {
//     final directory = Directory('/storage/emulated/0/Music/SongDownloader');
//     if (!await directory.exists()) {
//       await directory.create(recursive: true);
//     }
//     return '${directory.path}/$fileName.mp3';
//   } else {
//     final dir = await getApplicationDocumentsDirectory();
//     return '${dir.path}/$fileName.mp3';
//   }
// }

// Future<bool> requestStoragePermission(BuildContext context) async {
//   if (Platform.isAndroid) {
//     var status = await Permission.audio.status;
    
//     print('📱 Storage permission status: $status');
    
//     if (status.isGranted) {
//       return true;
//     }
    
//     if (status.isPermanentlyDenied) {
//       final shouldOpenSettings = await showDialog<bool>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Storage Permission Required'),
//           content: Text(
//             'This app needs storage permission to save songs. '
//             'Please enable it in app settings.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: Text('Open Settings'),
//             ),
//           ],
//         ),
//       );
      
//       if (shouldOpenSettings == true) {
//         await openAppSettings();
//       }
//       return false;
//     }
    
//     status = await Permission.audio.request();
//     print('📱 Permission after request: $status');
    
//     if (status.isDenied || status.isPermanentlyDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Storage permission is required'),
//           action: SnackBarAction(
//             label: 'Settings',
//             onPressed: () => openAppSettings(),
//           ),
//         ),
//       );
//       return false;
//     }
    
//     return status.isGranted;
//   }
//   return true;
// }

// Future<void> downloadSong(
//   BuildContext context,
//   String query, {
//   required void Function(double) onProgress,
//   required void Function(bool) onComplete,
// }) async {
//   try {
//     print('🚀 Starting download for: $query');
    
//     final hasPermission = await requestStoragePermission(context);
//     if (!hasPermission) {
//       print('❌ Permission denied');
//       onComplete(false);
//       return;
//     }

//     // Create Dio with explicit configuration
//     final dio = Dio(
//       BaseOptions(
//         connectTimeout: Duration(seconds: 30),
//         receiveTimeout: Duration(minutes: 5),
//         followRedirects: true,
//         validateStatus: (status) => status! < 500,
//       ),
//     );

//     // Add logging interceptor
//     dio.interceptors.add(LogInterceptor(
//       requestBody: true,
//       responseBody: false,
//       error: true,
//       requestHeader: true,
//       responseHeader: true,
//       request: true,
//     ));

//     final url = 'https://songdownloadbackend.onrender.com/download-by-query';
//     print('🌐 Connecting to: $url');
//     print('📱 Platform: ${Platform.operatingSystem}');
//     print('📱 Version: ${Platform.version}');

//     final postResponse = await dio.post(
//       url,
//       data: jsonEncode({'query': query}),
//       options: Options(
//         responseType: ResponseType.stream,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': '*/*',
//         },
//       ),
//     );

//     print('✅ Response status: ${postResponse.statusCode}');
//     print('📦 Headers: ${postResponse.headers}');

//     final filePath = await getDownloadPath(query);
//     print('💾 Saving to: $filePath');
    
//     final file = File(filePath);

//     final total = int.tryParse(
//       postResponse.headers.map['content-length']?.first ?? '0',
//     );
//     print('📊 Total size: ${total ?? "unknown"} bytes');

//     int received = 0;
//     final sink = file.openWrite();

//     await postResponse.data!.stream.listen(
//       (List<int> chunk) {
//         received += chunk.length;
//         sink.add(chunk);

//         if (total != null && total > 0) {
//           final progress = received / total;
//           onProgress(progress);
          
//           if (received % 100000 == 0) { // Log every 100KB
//             print('📥 Downloaded: ${(received / 1024 / 1024).toStringAsFixed(2)} MB');
//           }
//         }
//       },
//       onDone: () async {
//         await sink.close();
//         onProgress(1.0);
//         onComplete(true);
//         print('✅ Download complete: $filePath');
//         print('📁 File size: ${await file.length()} bytes');
//         _showPlayOrShareDialog(context, filePath, query);
//       },
//       onError: (e) async {
//         await sink.close();
//         print("❌ Stream error: $e");
//         onComplete(false);
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Download failed: $e')),
//         );
//       },
//       cancelOnError: true,
//     );
//   } catch (e) {
//     print('❌ Error type: ${e.runtimeType}');
//     print('❌ Error details: $e');
    
//     if (e is DioException) {
//       print('❌ DioException type: ${e.type}');
//       print('❌ DioException message: ${e.message}');
//       print('❌ DioException response: ${e.response}');
//     }
    
//     onComplete(false);
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('Download failed. Check console logs.'),
//         duration: Duration(seconds: 5),
//       ),
//     );
//   }
// }

// void _showPlayOrShareDialog(BuildContext context, String filePath, String songName) {
//   showDialog(
//     context: context,
//     builder: (context) => AlertDialog(
//       title: Text('Download complete!'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.check_circle, color: Colors.green, size: 48),
//           SizedBox(height: 16),
//           Text('Song saved successfully!'),
//           SizedBox(height: 8),
//           Text(
//             'Music/SongDownloader/$songName.mp3',
//             style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             _playMp3(context, filePath);
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.play_arrow, size: 20),
//               SizedBox(width: 4),
//               Text('Play'),
//             ],
//           ),
//         ),
//         TextButton(
//           onPressed: () {
//             Navigator.pop(context);
//             _shareSong(filePath);
//           },
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.share, size: 20),
//               SizedBox(width: 4),
//               Text('Share'),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }

// final AudioPlayer _audioPlayer = AudioPlayer();
// bool _isPlaying = false;

// Future<void> _playMp3(BuildContext context, String filePath) async {
//   try {
//     final file = File(filePath);
//     if (!await file.exists()) {
//       print('❌ File not found: $filePath');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Audio file not found')),
//       );
//       return;
//     }

//     print('🎵 File exists, size: ${await file.length()} bytes');

//     if (_isPlaying) {
//       await _audioPlayer.stop();
//     }

//     await _audioPlayer.play(DeviceFileSource(filePath));
//     _isPlaying = true;
    
//     print('🎵 Started playing: $filePath');
    
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(Icons.music_note, color: Colors.white),
//             SizedBox(width: 8),
//             Text('Now playing...'),
//           ],
//         ),
//         action: SnackBarAction(
//           label: 'Stop',
//           onPressed: () async {
//             await _audioPlayer.stop();
//             _isPlaying = false;
//           },
//         ),
//         duration: Duration(seconds: 3),
//       ),
//     );

//     _audioPlayer.onPlayerComplete.listen((event) {
//       _isPlaying = false;
//       print('🎵 Playback completed');
//     });
//   } catch (e) {
//     print('❌ Error playing audio: $e');
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error playing: $e')),
//     );
//   }
// }

// void _shareSong(String filePath) {
//   print('📤 Sharing: $filePath');
//   Share.shareXFiles([XFile(filePath)], text: 'Check out this song!');
// }