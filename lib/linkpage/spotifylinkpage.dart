import 'package:flutter/material.dart';
import 'package:songdownloader/linkpage/linkpagewidget.dart';

class SpotifyLinkPage extends StatefulWidget {
  const SpotifyLinkPage({super.key});

  @override
  State<SpotifyLinkPage> createState() => _SpotifyLinkPageState();
}

class _SpotifyLinkPageState extends State<SpotifyLinkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child:LinkBarWidget(platform: 'Spotify'),
      ),
    );
  }
}