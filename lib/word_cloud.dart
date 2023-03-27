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
import 'suggestions.dart';
import 'recording.dart';
import 'util/scatter_item.dart';
import 'util/flutter_hashtag.dart';
import 'util/elevated_button.dart';

class WordCloud extends StatefulWidget {
  const WordCloud({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _WordCloudState createState() => _WordCloudState();
}

class _WordCloudState extends State<WordCloud> {
  @override
  Widget build(BuildContext context) {
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
            bottom: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.category,
                  iconColor: Colors.blue,
                  onPressFunc: CategoriesPage,
                  text: "Categories",
                ),
                SizedBox(
                  width: 20,
                ),
                createElevatedButton(
                  icon: Icons.pie_chart,
                  iconColor: Colors.blue,
                  onPressFunc: PieChartPage,
                  text: "Pie Chart",
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.image_aspect_ratio,
                  iconColor: Colors.blue,
                  onPressFunc: RatioPage,
                  text: "Ratio",
                ),
                SizedBox(
                  width: 20,
                ),
                createElevatedButton(
                  icon: Icons.newspaper,
                  iconColor: Colors.blue,
                  onPressFunc: SuggestionsPage,
                  text: "Suggestions",
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.record_voice_over,
                  iconColor: Colors.blue,
                  onPressFunc: RecordingPage,
                  text: "Record",
                ),
              ],
            ),
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
  Future<void> SuggestionsPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Suggestions(title: 'Suggestions');
   }));
  }
  Future<void> RecordingPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Recording(title: 'Recording');
   }));
  }
}
