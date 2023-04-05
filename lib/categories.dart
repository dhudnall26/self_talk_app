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
import 'word_cloud.dart';
import 'pie_chart.dart';
import 'ratio.dart';
import 'ideas.dart';
import 'recording.dart';
import 'util/elevated_button.dart';
import 'util/bullet_points.dart';


class Categories extends StatefulWidget {
  const Categories({Key? key, required this.title}) : super(key: key);
  final String title;

@override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
      appBar: AppBar(centerTitle: true, title: Text('Categories')),
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
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Animals', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Painting', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Cooking', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Hiking', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Gardening', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
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
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Music', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                          new ListTile(
                              leading: new MyBullet(),
                              title: new Text('Swimming', style: TextStyle(fontSize: 15, color: Colors.blue)),
                          ),
                        ],
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
  Future<void> WordCloudPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const WordCloud(title: 'WordCloud');
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
