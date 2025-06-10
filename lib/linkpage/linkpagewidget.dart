import 'package:flutter/material.dart';

class LinkBarWidget extends StatefulWidget {
  final String platform;

  const LinkBarWidget({super.key, required this.platform});

  @override
  State<LinkBarWidget> createState() => _LinkBarWidgetState();
}

class _LinkBarWidgetState extends State<LinkBarWidget> {
  bool isDownloaded = false;
  final TextEditingController linkController = TextEditingController();
  void _processLink() async {
    final link = linkController.text.trim();
    if (link.isEmpty) return;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            width: screenWidth * 0.9,
            child: TextField(
              controller: linkController,
              textAlign: TextAlign.start,
              decoration: InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(231, 221, 220, 220),
                hintText: 'Input ${widget.platform} song link',
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.1,),
          ElevatedButton(onPressed: _processLink, child: Text('Download MP3')),
          isDownloaded ? Text('your shii is downloaded') : SizedBox()
        ],
      ),
    );
  }
}
