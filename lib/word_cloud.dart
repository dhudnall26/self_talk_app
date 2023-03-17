import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'package:flutter_scatter/flutter_scatter.dart';

class WordCloud extends StatefulWidget {
  const WordCloud({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _WordCloudState createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  @override
  Widget build(BuildContext context) {
    //List<Widget> widgets = <Widget>["cats", "dogs", "unicorns", "lizards", "humans", "ants"];
    List<Widget> widgets = <Widget>[];
    const kFlutterHashtags = [
      FlutterHashtag(hashtag: 'by', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'from', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'they', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'we', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'say', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'her', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'she', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'or', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'will', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'one', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'would', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'there', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'what', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'about', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'who', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'which', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'when', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'make', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'can', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'like', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'time', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'just', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'him', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'know', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'take', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'people', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'into', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'year', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'people', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'into', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'could', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'other', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'come', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'think', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'back', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'after', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'use', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'two', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'work', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'first', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'well', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'way', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'even', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'because', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'these', size: 16.0, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: 'give', size: 24.0, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: 'most', size: 20.0, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: 'days', size: 16.0, color: Colors.red, rotated: false),
    ];
    for (var i = 0; i < kFlutterHashtags.length; i++) {
      widgets.add(ScatterItem(kFlutterHashtags[i], i));
    }

    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;

    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Word Cloud')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.home,
                  iconColor: Colors.blue,
                  onPressFunc: backHome,
                ),
              ],
            ),
            FittedBox(
              child: Scatter(
                fillGaps: true,
                delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
                children: widgets,
              ),
            ),
          ],
        ),
      ),
    );
  }
  ElevatedButton createElevatedButton(
      {required IconData icon, required Color iconColor, final VoidCallback? onPressFunc}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.all(6.0),
        side: BorderSide(
          color: Colors.blue,
          width: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        primary: Colors.white,
        elevation: 9.0,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38.0,
      ),
      label: Text(''),
    );
  }

  Future<void> backHome() async {
    Navigator.pop(context);
  }
}
class ScatterItem extends StatelessWidget {
  ScatterItem(this.hashtag, this.index);
  final FlutterHashtag hashtag;
  final int index;
  final TextStyle _defaultTextStyle = TextStyle(fontSize: 16.0, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    final TextStyle style = Theme.of(context).textTheme?.bodyText1?.copyWith(
          fontSize: hashtag.size.toDouble(),
          color: hashtag.color,
        ) ?? TextStyle(fontSize: 16.0, color: Colors.black);
    return RotatedBox(
      quarterTurns: hashtag.rotated ? 1 : 0,
      child: Text(
        hashtag.hashtag,
        style: style,
      ),
    );
  }
}

class FlutterHashtag {
  final String hashtag;
  final double size;
  final Color color;
  final bool rotated;

  const FlutterHashtag({
    required this.hashtag,
    required this.size,
    required this.color,
    required this.rotated,
  });
}