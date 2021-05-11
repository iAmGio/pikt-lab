import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:piktlab/constants/lang.dart';
import 'package:piktlab/ui/page.dart';
import 'package:piktlab/ui/utils/gradients.dart';
import 'package:piktlab/ui/widgets/primary_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return new UIPage(
      decoration: BoxDecoration(
        gradient: Gradients.bgGradient,
      ),
      child: Stack(
        children: [
          SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SvgPicture.asset(
                  "images/logo_light.svg",
                  width: mediaQuery.size.width / 3,
                ),
                SizedBox(height: mediaQuery.size.height / 7),
                PrimaryButton(
                  text: lang['landing.newscript'],
                  width: mediaQuery.size.width / 4.4,
                  height: mediaQuery.size.width / 17,
                  icon: CupertinoIcons.add,
                  onPressed: () => {},
                ),
              ],
            ),
          ),
          IconButton(
            iconSize: mediaQuery.size.width / 28,
            color: Colors.white,
            onPressed: () {},
            icon: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }
}
