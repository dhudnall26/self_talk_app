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
import 'package:webview_flutter/webview_flutter.dart';

import 'main.dart';
import 'word_cloud.dart';
import 'categories.dart';
import 'pie_chart.dart';
import 'ratio.dart';
import 'recording.dart';
import 'util/elevated_button.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _SuggestionsState createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Suggestions')),
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
              SizedBox(
                width: 300,
                height: 200,
                // Inkwell
                child: InkWell(
                  radius: 100,
                  // display a snackbar on tap
                  onTap: backHome,
                  // implement the image with Ink.image
                  child: Ink.image(
                    fit: BoxFit.cover,
                    image: const NetworkImage(
                        'https://www.kindacode.com/wp-content/uploads/2022/07/bottle.jpeg'),
                    ),
                  ),
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
                  bottom: 120,
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
                  bottom: 70,
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
  Future<void> RatioPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Ratio(title: 'Ratio');
   }));
  }
  Future<void> RecordingPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Recording(title: 'Recording');
   }));
  }
  // Function to launch the web view
  // void launchWebView() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => Scaffold(
  //         appBar: AppBar(
  //           title: Text('Web View'),
  //         ),
  //         body: WebView(
  //           initialUrl: url,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}