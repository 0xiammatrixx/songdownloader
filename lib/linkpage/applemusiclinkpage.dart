import 'package:flutter/material.dart';
import 'package:songdownloader/linkwidget/linkpagewidget.dart';

class AppleMusicLinkPage extends StatelessWidget {
  const AppleMusicLinkPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LinkBarWidget(platform: 'AppleMusic'),
    );
  }
}