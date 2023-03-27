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
import 'package:pie_chart/pie_chart.dart';

import 'word_cloud.dart';
import 'categories.dart';
import 'pie_chart.dart';
import 'ratio.dart';
import 'suggestions.dart';
import 'recording.dart';
import 'util/scatter_item.dart';
import 'util/flutter_hashtag.dart';
import 'util/elevated_button.dart';
import 'util/bullet_points.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Talk to Me Nice',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Talk to Me Nice Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final recordingPlayer = AssetsAudioPlayer();
  bool _playAudio = false;
  String? recordedSession = "";
  late String? recorded_session;

  late String yamlString;
  late YamlMap yamlData;
  late String url;
  late String token;
  late SupabaseClient supabase;

  Future<void> yamlInit() async {
    yamlString = await rootBundle.loadString('vault/supabase_config.yaml');
    yamlData = loadYaml(yamlString);
    url = yamlData['STORAGE_URL'];
    token = yamlData['SERVICE_TOKEN'];
    supabase = SupabaseClient(url, token);
  }

  void initializer() async {
    await yamlInit();
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }

  @override
  void initState() {
    super.initState();
    initializer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initializer();
    }
  }

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

    Map<String, double> dataMap = {
      "Happy": 5,
      "Sad": 3,
      "Angry": 2,
      "Neutral": 2,
    };

    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Talk to Me Nice')),
      body: Stack(
        children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: Container(
                        color: Colors.cyan[100],
                        child: Center(
                          child: FittedBox(
                            child: Transform.scale(
                              scale: 0.75,
                              child: Scatter(
                                fillGaps: true,
                                delegate: ArchimedeanSpiralScatterDelegate(ratio: ratio),
                                children: widgets,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: Transform.scale(
                        scale: 0.75,
                        child: ListView(
                        shrinkWrap: true,
                          children: <Widget>[
                            new ListTile(
                                leading: new MyBullet(),
                                title: new Text('Programming', style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                            new ListTile(
                                leading: new MyBullet(),
                                title: new Text('Coloring', style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                            new ListTile(
                                leading: new MyBullet(),
                                title: new Text('Aromatherapy', style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: Container(
                        color: Colors.cyan[100],
                        child: Center(
                          child: FittedBox(
                            child: Transform.scale(
                              scale: 0.75,
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
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: Text(
                        "1:2",
                        style: TextStyle(fontSize: 70, color: Colors.blue),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: Container(
                color: Colors.cyan[100],
                child: Center(
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 70, color: Colors.blue),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createElevatedButton(
                      icon: Icons.wordpress,
                      iconColor: Colors.blue,
                      onPressFunc: WordCloudPage,
                      text: "Word Cloud",
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    createElevatedButton(
                      icon: Icons.category,
                      iconColor: Colors.blue,
                      onPressFunc: CategoriesPage,
                      text: "Categories",
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createElevatedButton(
                      icon: Icons.pie_chart,
                      iconColor: Colors.blue,
                      onPressFunc: PieChartPage,
                      text: "Pie Chart",
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    createElevatedButton(
                      icon: Icons.image_aspect_ratio,
                      iconColor: Colors.blue,
                      onPressFunc: RatioPage,
                      text: "Ratio",
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    createElevatedButton(
                      icon: Icons.newspaper,
                      iconColor: Colors.blue,
                      onPressFunc: SuggestionsPage,
                      text: "Suggestions",
                    ),
                    SizedBox(
                      width: 20,
                    ),
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
        ],
      ),
    );
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