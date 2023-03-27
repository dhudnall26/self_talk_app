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