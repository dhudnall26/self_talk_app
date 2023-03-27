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

import 'flutter_hashtag.dart';

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