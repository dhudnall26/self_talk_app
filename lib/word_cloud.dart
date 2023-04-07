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

import 'main.dart';
import 'categories.dart';
import 'pie_chart.dart';
import 'ratio.dart';
import 'ideas.dart';
import 'recording.dart';
import 'util/scatter_item.dart';
import 'util/flutter_hashtag.dart';
import 'util/elevated_button.dart';

List<String> mostCommonWords = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""];

Map<String, int> wordMap = {};

List<Widget> widgets = <Widget>[];

List<FlutterHashtag> kFlutterHashtags = [
  FlutterHashtag(hashtag: mostCommonWords[0], size: 30, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[1], size: 29.75, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[2], size: 29.5, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[3], size: 29.25, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[4], size: 29, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[5], size: 28.75, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[6], size: 28.5, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[7], size: 28.25, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[8], size: 28, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[9], size: 27.75, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[10], size: 27.5, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[11], size: 27.25, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[12], size: 27, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[13], size: 26.75, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[14], size: 26.5, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[15], size: 26.25, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[16], size: 26, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[17], size: 25.75, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[18], size: 25.5, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[19], size: 25.25, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[20], size: 25, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[21], size: 24.75, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[22], size: 24.5, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[23], size: 24.25, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[24], size: 24, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[25], size: 23.75, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[26], size: 23.5, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[27], size: 23.25, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[28], size: 23, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[29], size: 22.75, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[30], size: 22.5, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[31], size: 22.25, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[32], size: 22, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[33], size: 21.75, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[34], size: 21.5, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[35], size: 21.25, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[36], size: 21, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[37], size: 20.75, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[38], size: 20.5, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[39], size: 20.25, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[40], size: 20, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[41], size: 19.75, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[42], size: 19.5, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[43], size: 19.25, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[44], size: 19, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[45], size: 18.75, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[46], size: 18.5, color: Colors.green, rotated: true),
  FlutterHashtag(hashtag: mostCommonWords[47], size: 18.25, color: Colors.red, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[48], size: 18, color: Colors.blue, rotated: false),
  FlutterHashtag(hashtag: mostCommonWords[49], size: 17.75, color: Colors.green, rotated: true),
];

class WordCloud extends StatefulWidget {
  const WordCloud({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _WordCloudState createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < kFlutterHashtags.length; i++) {
      widgets.add(ScatterItem(kFlutterHashtags[i], i));
    }

    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;

    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Words')),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  createElevatedButton(
                    icon: Icons.home,
                    iconColor: Colors.blue,
                    onPressFunc: backHome,
                    text: "Home",
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  color: Colors.cyan[100],
                  child: Center(
                    child:             FittedBox(
                      child: Scatter(
                        fillGaps: true,
                        delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
                        children: widgets,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.category,
                  iconColor: Colors.blue,
                  onPressFunc: CategoriesPage,
                  text: "Topics",
                ),
                SizedBox(
                  width: 10,
                ),
                createElevatedButton(
                  icon: Icons.pie_chart,
                  iconColor: Colors.blue,
                  onPressFunc: PieChartPage,
                  text: "Moods",
                ),
                SizedBox(
                  width: 10,
                ),
                createElevatedButton(
                  icon: Icons.image_aspect_ratio,
                  iconColor: Colors.blue,
                  onPressFunc: RatioPage,
                  text: "+:-",
                ),
                SizedBox(
                  width: 10,
                ),
                createElevatedButton(
                  icon: Icons.newspaper,
                  iconColor: Colors.blue,
                  onPressFunc: IdeasPage,
                  text: "Ideas",
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
  Future<void> backHome() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const MyHomePage(title: 'Talk to Me Nice');
   }));
  }
  Future<void> CategoriesPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Categories(title: 'Categories');
   }));
  }
  Future<void> PieChartPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const PieCharts(title: 'PieChart');
   }));
  }
  Future<void> RatioPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Ratio(title: 'Ratio');
   }));
  }
  Future<void> IdeasPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Ideas(title: 'Ideas');
   }));
  }
  Future<void> RecordingPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Recording(title: 'Recording');
   }));
  }
}
