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
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Animals', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Painting', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Cooking', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Hiking', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Gardening', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Programming', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Coloring', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Aromatherapy', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Music', style: TextStyle(color: Colors.blue)),
            ),
            new ListTile(
              leading: new MyBullet(),
              title: new Text('Swimming', style: TextStyle(color: Colors.blue)),
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

class MyBullet extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new Container(
    height: 20.0,
    width: 20.0,
    decoration: new BoxDecoration(
    color: Colors.blue,
    shape: BoxShape.circle,
  ),
  );
  }
}