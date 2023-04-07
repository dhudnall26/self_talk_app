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
import 'package:pie_chart/pie_chart.dart';

import 'main.dart';
import 'word_cloud.dart';
import 'categories.dart';
import 'ratio.dart';
import 'ideas.dart';
import 'recording.dart';
import 'util/elevated_button.dart';

Map<String, double> dataMap = {
  "% Happy": 0,
  "% Sad": 0,
  "% Angry": 0,
  "% Neutral": 0,
};
double happy = 0;
double sad = 0;
double angry = 0;
double neutral = 0;
double happyPercent = 0;
double sadPercent = 0;
double angryPercent = 0;
double neutralPercent = 0;

class PieCharts extends StatefulWidget {
  const PieCharts({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _PieChartsState createState() => _PieChartsState();
}

class _PieChartsState extends State<PieCharts> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Pie Chart')),
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
              Expanded(
                child: Container(
                  color: Colors.cyan[100],
                  child: PieChart(
                    dataMap: dataMap,
                    chartRadius: MediaQuery.of(context).size.width / 2.0,
                    chartType: ChartType.ring,
                    colorList: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
                    legendOptions: LegendOptions(
                      showLegends: true,
                    ),
                  ),
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