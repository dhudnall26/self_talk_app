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
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:googleapis/speech/v1.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';

import 'package:http/http.dart' as http;

import 'word_cloud.dart';
import 'categories.dart';
import 'pie_chart.dart';
import 'ratio.dart';
import 'ideas.dart';
import 'recording.dart';
import 'util/scatter_item.dart';
import 'util/flutter_hashtag.dart';
import 'util/elevated_button.dart';
import 'util/bullet_points.dart';

List<String> mostCommonWords = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""];

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
  String positiveRatioString = positiveRatio.toString();
  String negativeRatioString = negativeRatio.toString();
  Map<String, double>  wordMap = {};
  List<String> keyWordScoreList = <String>[];
  Map<String, int> categoryMap = {};
  Map<String, int> secondMap = {};
  Map<String, int> thirdMap = {}; 
  List<String> word_cloud_words = [];
  Map<String, num> wordFrequencies = {};
  final recordingPlayer = AssetsAudioPlayer();
  bool _playAudio = false;
  bool _recordAudio = false;
  String? recordedSession = "";
  late String? recorded_session;
    late FlutterSoundRecorder _recordingSession;
  String fileName = 'voice_recording.wav';
  String pathToAudio = '/sdcard/Recordings/voice_recording.wav';

  late String private_key_id;
  late String private_key;
  late String client_email;
  late String client_id;
  late AuthClient google_client;
  late SpeechApi speech;
  String display_transcript = "";
  late String? transcript;

  late String open_ai_key;

  late String yamlString;
  late YamlMap yamlData;
  late String url;
  late String token;
  late SupabaseClient supabase;

  late RecognitionAudio audio;
  late RecognitionConfig config;

  String keyWithMaxValue = "";
  String keyWithSecondMaxValue = "";
  String keyWithThirdMaxValue = "";

    List<Widget> widgets = <Widget>[];
    List<FlutterHashtag> kFlutterHashtags = [
      FlutterHashtag(hashtag: mostCommonWords[0], size: 30, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[1], size: 29.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[2], size: 29.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[3], size: 29.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[4], size: 29, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[5], size: 28.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[6], size: 28.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[7], size: 28.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[8], size: 28, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[9], size: 27.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[10], size: 27.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[11], size: 27.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[12], size: 27, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[13], size: 26.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[14], size: 26.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[15], size: 26.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[16], size: 26, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[17], size: 25.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[18], size: 25.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[19], size: 25.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[20], size: 25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[21], size: 24.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[22], size: 24.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[23], size: 24.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[24], size: 24, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[25], size: 23.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[26], size: 23.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[27], size: 23.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[28], size: 23, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[29], size: 22.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[30], size: 22.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[31], size: 22.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[32], size: 22, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[33], size: 21.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[34], size: 21.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[35], size: 21.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[36], size: 21, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[37], size: 20.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[38], size: 20.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[39], size: 20.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[40], size: 20, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[41], size: 19.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[42], size: 19.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[43], size: 19.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[44], size: 19, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[45], size: 18.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[46], size: 18.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[47], size: 18.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[48], size: 18, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[49], size: 17.75, color: Colors.green, rotated: true),
    ];

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

    yamlString = await rootBundle.loadString('vault/open_ai.yaml');
    yamlData = loadYaml(yamlString);
    open_ai_key = yamlData['KEY'];
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
    widgets = <Widget>[];
    for (var i = 0; i < kFlutterHashtags.length; i++) {
      widgets.add(ScatterItem(kFlutterHashtags[i], i));
    }
    final screenSize = MediaQuery.of(context).size;
    final ratio = screenSize.width / screenSize.height;

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
                ],
              ),
              Row(
                children: <Widget>[
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
                                title: new Text(keyWithMaxValue, style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                            new ListTile(
                                leading: new MyBullet(),
                                title: new Text(keyWithSecondMaxValue, style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                            new ListTile(
                                leading: new MyBullet(),
                                title: new Text(keyWithThirdMaxValue, style: TextStyle(fontSize: 15, color: Colors.blue)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                      color: Colors.cyan[100],
                      child: Text(
                        "$positiveRatioString:$negativeRatioString",
                        style: TextStyle(fontSize: 70, color: Colors.blue),
                      ),
                    ),
                  ),
                ]
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
                      text: "Words",
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    createElevatedButton(
                      icon: Icons.category,
                      iconColor: Colors.blue,
                      onPressFunc: CategoriesPage,
                      text: "Topics",
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    createElevatedButton(
                      icon: Icons.pie_chart,
                      iconColor: Colors.blue,
                      onPressFunc: PieChartPage,
                      text: "Moods",
                    ),
                    SizedBox(
                      width: 3,
                    ),
                    createElevatedButton(
                      icon: Icons.image_aspect_ratio,
                      iconColor: Colors.blue,
                      onPressFunc: RatioPage,
                      text: "+:-",
                    ),
                    SizedBox(
                      width: 3,
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
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      style:
                          ElevatedButton.styleFrom(elevation: 9.0, primary: Colors.red),
                      onPressed: () {
                        setState(() {
                          _recordAudio = !_recordAudio;
                        });
                        if (_recordAudio) startRecording();
                        if (!_recordAudio) stopRecording();
                      },
                      icon: _recordAudio
                          ? Icon(
                              Icons.stop,
                            )
                          : Icon(Icons.mic),
                      label: _recordAudio
                          ? Text(
                              "Stop Recording",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            )
                          : Text(
                              "Record",
                              style: TextStyle(
                                fontSize: 28,
                              ),
                            ),
                    ),
                    SizedBox(
                      width: 20,
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
              SizedBox(
                height: 20,
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
  Future<void> IdeasPage() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const Ideas(title: 'Ideas');
   }));
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

    print("Transcript");
    print(display_transcript);

    String sentimentScore = await getSentiment(display_transcript);
    print("Sentiment");
    print(sentimentScore);
    if (sentimentScore.contains("positive")) {
      positiveRatio += 1;
    } else if (sentimentScore.contains("negative")) {
      negativeRatio += 1;
    }
    setState((){
      positiveRatioString = positiveRatio.toString();
      negativeRatioString = negativeRatio.toString();
    });

    /////////////////////////////+++++++++++++++/////////////////

    String emotionScore = await getEmotion(display_transcript);
    print("Emotion");
    print(emotionScore);

    if (emotionScore.contains('sad')) {
      sad += 1;
    } else if (emotionScore.contains('angry')) {
      angry += 1;
    } else if (emotionScore.contains('happy')) {
      happy += 1;
    } else if (emotionScore.contains('neutral')) {
      neutral += 1;
    }

    happyPercent = ((happy / (happy + sad + angry + neutral)) * 100);
    sadPercent = ((sad / (happy + sad + angry + neutral)) * 100);
    angryPercent = ((angry / (happy + sad + angry + neutral)) * 100);
    neutralPercent = ((neutral / (happy + sad + angry + neutral)) * 100);

    setState((){
      dataMap = {
        "% Happy": happyPercent,
        "% Sad": sadPercent,
        "% Angry": angryPercent,
        "% Neutral": neutralPercent,
      };
    });


    //////////////////////+++++++++++++++++++++++////////////////

    String keyWordScore = await getKeyWords(display_transcript);
    print("Key Word");
    print(keyWordScore);

    List<String> keyWordsList = keyWordScore.split(",");

    for (var item in keyWordsList) {
      word_cloud_words.add(item.replaceAll(RegExp(r'[\n\s]+'), ''));
    }



    // Iterate through the list of words and count their occurrences
    for (String word in word_cloud_words) {
      if (wordFrequencies.containsKey(word)) {
        wordFrequencies[word] = wordFrequencies[word]! + 1;
      } else {
        wordFrequencies[word] = 1;
      }
    }
    word_cloud_words = [];

    // Sort the Map entries by value in descending order
    var sortedEntries = wordFrequencies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get the 50 most common words
    for (int i = 0; i < 50 && i < sortedEntries.length; i++) {
      mostCommonWords[i] = (sortedEntries[i].key);
    }

    setState((){
      kFlutterHashtags = [
      FlutterHashtag(hashtag: mostCommonWords[0], size: 30, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[1], size: 29.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[2], size: 29.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[3], size: 29.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[4], size: 29, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[5], size: 28.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[6], size: 28.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[7], size: 28.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[8], size: 28, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[9], size: 27.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[10], size: 27.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[11], size: 27.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[12], size: 27, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[13], size: 26.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[14], size: 26.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[15], size: 26.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[16], size: 26, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[17], size: 25.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[18], size: 25.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[19], size: 25.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[20], size: 25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[21], size: 24.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[22], size: 24.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[23], size: 24.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[24], size: 24, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[25], size: 23.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[26], size: 23.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[27], size: 23.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[28], size: 23, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[29], size: 22.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[30], size: 22.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[31], size: 22.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[32], size: 22, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[33], size: 21.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[34], size: 21.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[35], size: 21.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[36], size: 21, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[37], size: 20.75, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[38], size: 20.5, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[39], size: 20.25, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[40], size: 20, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[41], size: 19.75, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[42], size: 19.5, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[43], size: 19.25, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[44], size: 19, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[45], size: 18.75, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[46], size: 18.5, color: Colors.green, rotated: true),
      FlutterHashtag(hashtag: mostCommonWords[47], size: 18.25, color: Colors.red, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[48], size: 18, color: Colors.blue, rotated: false),
      FlutterHashtag(hashtag: mostCommonWords[49], size: 17.75, color: Colors.green, rotated: true),
    ];
    });

    print("The 50 most common words are: $mostCommonWords");

    String categoryScore = await getCategory(display_transcript);
    print("Category");
    print(categoryScore);

    if (categoryMap.containsKey(categoryScore)) {
      categoryMap[categoryScore] = categoryMap[categoryScore]! + 1;
    }
    else {
      categoryMap[categoryScore] = 1;
    }

    print("Category Map");
    print(categoryMap);

    String getMaxKey(Map<String, int> map) {
    int maxValue = 0;
    String maxKey = '';

    // Iterate through the map
    map.forEach((key, value) {
      if (value > maxValue) {
        maxValue = value;
        maxKey = key;
      }
    });

    return maxKey;
  }

  secondMap = Map.from(categoryMap);
  secondMap.remove(keyWithMaxValue);

  thirdMap = Map.from(secondMap);
  thirdMap.remove(keyWithSecondMaxValue);

    setState(() {
      keyWithMaxValue = getMaxKey(categoryMap);
      keyWithSecondMaxValue = getMaxKey(secondMap);
      keyWithThirdMaxValue = getMaxKey(thirdMap);
    });

  print('Key with maximum value: $keyWithMaxValue');
  print('Key with second max value: $keyWithSecondMaxValue');
  print('Key with third max value: $keyWithThirdMaxValue');

  print("Open AI Key");
  print(open_ai_key);

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
        'Authorization': 'Bearer $open_ai_key',
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

    print("response");
    print(response.body);

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
        'Authorization': 'Bearer $open_ai_key',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'Is this emotion happy, sad, angry, or neutral? $text : \n\nemotion: ',
        'max_tokens': 60,
        'temperature': 0,
        'n': 1,
        'stop': '.'
      }),
    );

    print("response");
    print(response.body);

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
        'Authorization': 'Bearer $open_ai_key',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'Extract keywords from this text and return a string separated by commas:\n\n $text',
        'max_tokens': 60,
        'temperature': 0.5,
        'n': 1,
        'stop': '.'
      }),
    );

    print("response");
    print(response.body);

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
        'Authorization': 'Bearer $open_ai_key',
      },
      body: jsonEncode({
        'model': 'text-davinci-003',
        'prompt': 'Extract categories from this text:\n\n $text \nCategory:',
        'max_tokens': 64,
        'temperature': 0,
        'n': 1,
        'stop': '.'
      }),
    );

    print("response");
    print(response.body);

    final json = jsonDecode(response.body);
    final sentiment = json['choices'][0]['text'].toString().toLowerCase();
    return sentiment;
  } catch (e) {
    print('Error getting categories: $e');
    return '';
  }
}
}