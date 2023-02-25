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
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FlutterSoundRecorder _recordingSession = FlutterSoundRecorder();
  final recordingPlayer = AssetsAudioPlayer();
  String pathToAudio = '/sdcard/Recordings/voice_recording.wav';
  bool _playAudio = false;
  String _timerText = '00:00:00';
  @override
  void initState() {
    super.initState();
    initializer();
  }
  void initializer() async {
    pathToAudio = '/sdcard/Recordings/voice_recording' + DateTime.now().millisecondsSinceEpoch.toString() + '.wav';
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
        focus: AudioFocus.requestFocusAndStopOthers,
        category: SessionCategory.playAndRecord,
        mode: SessionMode.modeDefault,
        device: AudioDevice.speaker);
    await _recordingSession.setSubscriptionDuration(Duration(milliseconds: 10));
    await initializeDateFormatting();
    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(title: Text('Audio Recording and Playing')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 40,
            ),
            Container(
              child: Center(
                child: Text(
                  _timerText,
                  style: TextStyle(fontSize: 70, color: Colors.red),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.mic,
                  iconColor: Colors.red,
                  onPressFunc: startRecording,
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.red,
                  onPressFunc: stopRecording,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
              onPressed: () {
                setState(() {
                  _playAudio = !_playAudio;
                });
                if (_playAudio) playFunc();
                if (!_playAudio) stopPlayFunc();
              },
              icon: _playAudio
                  ? Icon(
                      Icons.stop,
                    )
                  : Icon(Icons.play_arrow),
              label: _playAudio
                  ? Text(
                      "Stop",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    )
                  : Text(
                      "Play",
                      style: TextStyle(
                        fontSize: 28,
                      ),
                    ),
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
          color: Colors.red,
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
  Future<void> startRecording() async {
    _counter++;
    pathToAudio = '/sdcard/Recordings/voice_recording' + DateTime.now().millisecondsSinceEpoch.toString() + '.wav';
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession.openAudioSession();
    await _recordingSession.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
    // StreamSubscription _recorderSubscription =
    //     _recordingSession.onProgress.listen((e) {
    //   var date = DateTime.fromMillisecondsSinceEpoch(e.duration.inMilliseconds,
    //       isUtc: true);
    //   var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
    //   setState(() {
    //     _timerText = timeText.substring(0, 8);
    //   });
    // });
    // _recorderSubscription.cancel();
  }
  Future<String?> stopRecording() async {
    _recordingSession.closeAudioSession();
    return await _recordingSession.stopRecorder();
  }
  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio),
      autoStart: true,
      showNotification: true,
    );
  }
  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}