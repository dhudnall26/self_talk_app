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

import 'main.dart';
import 'dashboard.dart';
import 'word_cloud.dart';
import 'categories.dart';
import 'pie_chart.dart';
// import 'ideas.dart';
import 'recording.dart';
import 'util/elevated_button.dart';

class Ratio extends StatefulWidget {
  const Ratio({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _RatioState createState() => _RatioState();
}

class _RatioState extends State<Ratio> {
  String positiveRatioString = positiveRatio.toString();
  String negativeRatioString = negativeRatio.toString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Ratio')),
      body: Stack(
        children: <Widget>[
          Column(
          mainAxisAlignment: MainAxisAlignment.start,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "The ratio displays the proportion \nof positive to negative sentiments \nover time.",
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ],
            ),
            Expanded(
              child: Container(
                color: Colors.cyan[100],
                child: Center(
                  child: Text(
                    "+:-\n$positiveRatioString:$negativeRatioString",
                    style: TextStyle(fontSize: 70, color: Colors.blue),
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
                  icon: Icons.wordpress,
                  iconColor: Colors.blue,
                  onPressFunc: WordCloudPage,
                  text: "Words",
                ),
                SizedBox(
                  width: 10,
                ),
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
                // SizedBox(
                //   width: 10,
                // ),
                // createElevatedButton(
                //   icon: Icons.newspaper,
                //   iconColor: Colors.blue,
                //   onPressFunc: IdeasPage,
                //   text: "Ideas",
                // ),
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
  Future<void> WordCloudPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const WordCloud(title: 'WordCloud');
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
  // Future<void> IdeasPage() async {
  //  Navigator.push(context, MaterialPageRoute(builder: (context) {
  //    return const Ideas(title: 'Ideas');
  //  }));
  // }
  Future<void> RecordingPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Recording(title: 'Recording');
   }));
  }
}