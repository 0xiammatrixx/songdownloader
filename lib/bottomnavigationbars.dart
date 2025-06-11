import 'package:flutter/material.dart';

class BottomNavigationBars extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavigationBars({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(items: [ 
      BottomNavigationBarItem(label: '',icon: Icon(Icons.sync_alt)),
      BottomNavigationBarItem(label: 'MP3 Downloader',icon: Icon(Icons.music_note)),
      BottomNavigationBarItem(label: '',icon: Icon(Icons.download)),
      ], currentIndex: currentIndex, onTap: onTap,);
  }
}