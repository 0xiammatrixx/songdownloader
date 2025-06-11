import 'package:flutter/material.dart';
import 'package:songdownloader/linkwidget/linkpagewidget.dart';

class AmazonLinkPage extends StatelessWidget {
  const AmazonLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LinkBarWidget(platform: 'AmazonMusic'),
    );
  }
}