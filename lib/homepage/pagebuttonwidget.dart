import 'package:flutter/material.dart';

class SelectPlatformButton extends StatelessWidget {
  final String platform;
  final String platformImage;
  final Color color;
  final Color textColor;
  final Widget routePage;
  const SelectPlatformButton({
    super.key,
    required this.platform,
    required this.platformImage,
    required this.color,
    required this.textColor,
    required this.routePage
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15)
      ),
      padding: EdgeInsets.all(8),
      height: screenHeight * 0.12,
      width: screenWidth * 0.9,
      child: ElevatedButton(style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        alignment: Alignment.centerLeft,
        
      ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => routePage));
        },
        child: Row(
          children: [
            Image.asset(
              platformImage,
              fit: BoxFit.contain,
              height: screenHeight * 0.12,
              width: screenWidth * 0.08,
            ),
            SizedBox(width: screenWidth * 0.05),
            Text('Download song from $platform', style: TextStyle(color: textColor),),
          ],
        ),
      ),
    );
  }
}
