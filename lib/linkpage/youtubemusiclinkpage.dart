import 'package:flutter/material.dart';
import 'package:songdownloader/linkwidget/linkpagewidget.dart';

class YoutubeMusicLinkPage extends StatelessWidget {
  const YoutubeMusicLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LinkBarWidget(platform: 'YTMusic'),
    );
  }
}