import 'package:flutter/material.dart';
import 'package:songdownloader/linkwidget/linkpagewidget.dart';

class DeezerLinkPage extends StatelessWidget {
  const DeezerLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LinkBarWidget(platform: 'Deezer'),
    );
  }
}