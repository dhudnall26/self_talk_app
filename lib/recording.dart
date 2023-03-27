import 'dart:async';
import 'dart:convert';
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

import 'package:googleapis/speech/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'main.dart';

class Recording extends StatefulWidget {
  const Recording({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _RecordingState createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  int _counter = 0;
  late FlutterSoundRecorder _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  String fileName = 'voice_recording.wav';
  String pathToAudio = '/sdcard/Recordings/voice_recording.wav';
  bool _playAudio = false;
  String? recordedSession = "";
  late String? recorded_session;
  String _timerText = '00:00:00';

  late String yamlString;
  late YamlMap yamlData;
  late String url;
  late String token;
  late SupabaseClient supabase;

  late String private_key_id;
  late String private_key;
  late String client_email;
  late String client_id;
  late AuthClient google_client;
  late SpeechApi speech;
  String display_transcript = "no words";
  late String? transcript;

  late RecognitionAudio audio;
  late RecognitionConfig config;

  Future<void> yamlInit() async {
    yamlString = await rootBundle.loadString('vault/supabase_config.yaml');
    yamlData = loadYaml(yamlString);
    url = yamlData['STORAGE_URL'];
    token = yamlData['SERVICE_TOKEN'];
    supabase = SupabaseClient(url, token);

    yamlString = await rootBundle.loadString('vault/google_config.yaml');
    yamlData = loadYaml(yamlString);
    private_key_id = yamlData['PRIVATE_KEY_ID'];
    private_key = yamlData['PRIVATE_KEY'];
    client_email = yamlData['CLIENT_EMAIL'];
    client_id = yamlData['CLIENT_ID'];
    final _credentials = ServiceAccountCredentials.fromJson({
          "private_key_id": private_key_id,
          "private_key": private_key,
          "client_email": client_email,
          "client_id": client_id,
          "type": "service_account"
        });
    google_client = await clientViaServiceAccount(_credentials, [SpeechApi.cloudPlatformScope]);
  }

  void initializer() async {
    await yamlInit();
    fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.wav';
    pathToAudio = '/sdcard/Recordings/voice_recording' + fileName;
    _recordingSession = FlutterSoundRecorder();
    await _recordingSession.openAudioSession(
      focus: AudioFocus.requestFocusAndStopOthers,
      category: SessionCategory.playAndRecord,
      mode: SessionMode.modeDefault,
      device: AudioDevice.speaker,
    );
    await _recordingSession.setSubscriptionDuration(Duration(milliseconds: 10));
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
  void dispose() {
    _recordingSession.closeAudioSession();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[100],
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
                  style: TextStyle(fontSize: 70, color: Colors.blue),
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
                  iconColor: Colors.blue,
                  onPressFunc: startRecording,
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.blue,
                  onPressFunc: stopRecording,
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.home,
                  iconColor: Colors.blue,
                  onPressFunc: backHome,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.blue),
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
            Container(
              child: Center(
                child: Text(
                  display_transcript,
                  style: TextStyle(fontSize: 20, color: Colors.blue),
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
  Future<void> startRecording() async {
    yamlInit();
    _counter++;
    fileName = DateTime.now().millisecondsSinceEpoch.toString() + '.wav';
    pathToAudio = '/sdcard/Recordings/voice_recording' + fileName;
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    _recordingSession.openAudioSession();
    await _recordingSession.startRecorder(
      toFile: pathToAudio,
      codec: Codec.pcm16WAV,
    );
  }
  Future<void> uploadFile(String fileName, String filePath) async {
    final response = await supabase.storage.from('self-talk-app').upload(fileName, File(filePath));
  }

  Future<String?> stopRecording() async {
    _recordingSession.closeAudioSession();
    recorded_session = await _recordingSession.stopRecorder();

    final file = File(pathToAudio);
    final audioBytes = await file.readAsBytes();
    final audioContent = base64Encode(audioBytes);
    final audio = RecognitionAudio(content: audioContent);
    final speech = SpeechApi(google_client).speech;
    final config = RecognitionConfig(
        sampleRateHertz: 16000,
        languageCode: 'en-US',
    );
    final response = await speech.recognize(  
      RecognizeRequest(
        config: config,
        audio: audio,
      ),
    );
    

    response.results?.forEach((result) {
      final transcript = result.alternatives?.first?.transcript;
      setState(() {
        display_transcript = transcript!;
      });
    });

    uploadFile(fileName, pathToAudio);
    return recorded_session;
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
  Future<void> backHome() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const MyHomePage(title: 'Talk to Me Nice');
   }));
  }
}