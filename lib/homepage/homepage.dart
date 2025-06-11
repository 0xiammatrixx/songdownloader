import 'package:flutter/material.dart';
import 'package:songdownloader/bottomnavigationbars.dart';
import 'package:songdownloader/converter/converterpage.dart';
import 'package:songdownloader/downloadyt/ytdownloadpage.dart';
import 'package:songdownloader/homepage/pagebuttonwidget.dart';
import 'package:songdownloader/linkpage/amazonmusiclinkpage.dart';
import 'package:songdownloader/linkpage/applemusiclinkpage.dart';
import 'package:songdownloader/linkpage/deezerlinkpage.dart';
import 'package:songdownloader/linkpage/spotifylinkpage.dart';
import 'package:songdownloader/linkpage/youtubemusiclinkpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;

  late final PageController _pageController = PageController(initialPage: _selectedIndex);

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBars(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          UploadVideoConverterPage(),
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: screenWidth * 0.13),
                  Text(
                    'Download MP3 to your device',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Column(
                    children: [
                      SelectPlatformButton(
                        textColor: Colors.white,
                        platform: 'Spotify',
                        platformImage: 'assets/spotify.png',
                        color: Colors.black,
                        routePage: SpotifyLinkPage(),
                      ),
                      SelectPlatformButton(
                        textColor: Colors.black,
                        platform: 'Apple Music',
                        platformImage: 'assets/applemusic.png',
                        color: Colors.white,
                        routePage: AppleMusicLinkPage(),
                      ),
                      SelectPlatformButton(
                        textColor: Colors.white,
                        platform: 'Deezer',
                        platformImage: 'assets/deezer.png',
                        color: Colors.black,
                        routePage: DeezerLinkPage(),
                      ),
                      SelectPlatformButton(
                        textColor: Colors.black,
                        platform: 'YT Music',
                        platformImage: 'assets/youtubemusic.png',
                        color: Colors.white,
                        routePage: YoutubeMusicLinkPage(),
                      ),
                      SelectPlatformButton(
                        textColor: Colors.white,
                        platform: 'Amazon Music',
                        platformImage: 'assets/amazonmusic.png',
                        color: Colors.black,
                        routePage: AmazonLinkPage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          YTDownloadPage(),
        ],
      ),
    );
  }
}
