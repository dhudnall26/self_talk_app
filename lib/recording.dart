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

import 'package:http/http.dart' as http;

import 'main.dart';
import 'dashboard.dart';
import 'word_cloud.dart';
import 'ratio.dart';
import 'util/elevated_button.dart';

class Recording extends StatefulWidget {
  const Recording({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _RecordingState createState() => _RecordingState();
}

class _RecordingState extends State<Recording> {
  late FlutterSoundRecorder _recordingSession;
  final recordingPlayer = AssetsAudioPlayer();
  String fileName = 'voice_recording.wav';
  String pathToAudio = '/sdcard/Recordings/voice_recording.wav';
  bool _playAudio = false;
  String? recordedSession = "";
  late String? recorded_session;

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
  String display_transcript = "";
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                createElevatedButton(
                  icon: Icons.mic,
                  iconColor: Colors.blue,
                  onPressFunc: startRecording,
                  text: "Record",
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.stop,
                  iconColor: Colors.blue,
                  onPressFunc: stopRecording,
                  text: "Stop",
                ),
                SizedBox(
                  width: 30,
                ),
                createElevatedButton(
                  icon: Icons.home,
                  iconColor: Colors.blue,
                  onPressFunc: backHome,
                  text: "Home",
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
  Future<void> startRecording() async {
    yamlInit();
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

    String sentimentScore = await getSentiment(display_transcript);
    print("Sentiment");
    print(sentimentScore);
    if (sentimentScore.contains("positive")) {
      positiveRatio += 1;
    } else if (sentimentScore.contains("negative")) {
      negativeRatio += 1;
    }

    String emotionScore = await getEmotion(display_transcript);
    print("Emotion");
    print(emotionScore);

    String keyWordScore = await getKeyWords(display_transcript);
    print("Key Word");
    print(keyWordScore);

    List<String> keyWordScoreList = keyWordScore.split(',');
    for (var item in keyWordScoreList) {
      if (wordMap.containsKey(item)) {
        wordMap[item] = wordMap[item]! + 1;
      }
      else {
        wordMap[item] = 0;
      }
    }
    print(wordMap);

    String categoryScore = await getCategory(display_transcript);
    print("Category");
    print(categoryScore);

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
  Future<String> getSentiment(String text) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'Decide whether a Tweets sentiment is positive, neutral, or negative.\n\nTweet: \ $text \nSentiment:',
        'max_tokens': 60,
        'temperature': 0,
        'n': 1,
        'stop': '.'
      }),
    );

    final json = jsonDecode(response.body);
    final sentiment = json['choices'][0]['text'].toString().toLowerCase();
    return sentiment;
  } catch (e) {
    print('Error getting sentiment: $e');
    return '';
  }
}

  Future<String> getEmotion(String text) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'The CSS code for a color like $text : \n\nbackground-color: #',
        'max_tokens': 60,
        'temperature': 0,
        'n': 1,
        'stop': '.'
      }),
    );

    final json = jsonDecode(response.body);
    final sentiment = json['choices'][0]['text'].toString().toLowerCase();
    return sentiment;
  } catch (e) {
    print('Error getting sentiment: $e');
    return '';
  }
}

  Future<String> getKeyWords(String text) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'Extract keywords from this text:\n\n $text',
        'max_tokens': 60,
        'temperature': 0.5,
        'n': 1,
        'stop': '.'
      }),
    );

    final json = jsonDecode(response.body);
    final sentiment = json['choices'][0]['text'].toString().toLowerCase();
    return sentiment;
  } catch (e) {
    print('Error getting keywords: $e');
    return '';
  }
}

  Future<String> getCategory(String text) async {
  try {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer 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',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'The following is a list of companies and the categories they fall into:\n\n $text \nCategory:',
        'max_tokens': 64,
        'temperature': 0,
        'n': 1,
        'stop': '.'
      }),
    );

    final json = jsonDecode(response.body);
    final sentiment = json['choices'][0]['text'].toString().toLowerCase();
    return sentiment;
  } catch (e) {
    print('Error getting categories: $e');
    return '';
  }
}
}