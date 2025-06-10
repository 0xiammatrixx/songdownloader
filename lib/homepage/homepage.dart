import 'package:flutter/material.dart';
import 'package:songdownloader/homepage/pagebuttonwidget.dart';
import 'package:songdownloader/linkpage/amazonmusiclinkpage.dart';
import 'package:songdownloader/linkpage/applemusiclinkpage.dart';
import 'package:songdownloader/linkpage/deezerlinkpage.dart';
import 'package:songdownloader/linkpage/spotifylinkpage.dart';
import 'package:songdownloader/linkpage/youtubemusiclinkpage.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(items: [ 
      BottomNavigationBarItem(label: '',icon: Icon(Icons.sync_alt)),
      BottomNavigationBarItem(label: 'MP3 downloader',icon: Icon(Icons.music_note)),
      BottomNavigationBarItem(label: '',icon: Icon(Icons.download)),
      ]),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: screenWidth * 0.1,
              ),
              Text('Download MP3 to your device', style: TextStyle(fontWeight: FontWeight.bold),),
              SizedBox(height: screenHeight * 0.1,),
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
    );
  }
}
