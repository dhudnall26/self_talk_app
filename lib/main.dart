import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:yaml/yaml.dart';
import 'package:storage_client/src/types.dart';

import 'word_cloud.dart';
import 'categories.dart';
import 'pie_chart.dart';
import 'util/flutter_hashtag.dart';

Map<String, num> wordFrequencies = {};
double happy = 0;
double sad = 0;
double angry = 0;
double neutral = 0;
var positiveRatio = 0;
var negativeRatio = 0;
Map<String, int> categoryMap = {};
List<String> topTenKeys = [];

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
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  //final _passwordController = TextEditingController();
  late String yamlString;
  late YamlMap yamlData;
  late String url;
  late String token;
  late SupabaseClient supabase;
  String waiting_message = "";
  dynamic storedData = null;
  Map<String, dynamic> storedDataMap = {};

  void initializer() async {
    yamlString = await rootBundle.loadString('vault/supabase_config.yaml');
    yamlData = loadYaml(yamlString);
    url = yamlData['STORAGE_URL'];
    token = yamlData['SERVICE_TOKEN'];
    supabase = SupabaseClient(url, token);
  }

  @override
  void initState() {
    super.initState();
    initializer();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
	  email = _emailController.text;
	  //password = _passwordController.text;
	  //if (email == password) {
		final folderPath = '$email/';

		final folderList = await supabase.storage.from('self-talk-app').list();
		final finalList = folderList.map((file) => file.name).toList();
		final folderExists = finalList.contains(email);

		if (folderExists) {
		  print('Folder already exists');
      setState(() {
        waiting_message = "... loading user data \n please wait ...";
      });

      wordFrequencies = await getWordFrequencies(email);
      sad = await getSad(email);
      happy = await getHappy(email);
      angry = await getAngry(email);
      neutral = await getNeutral(email);
      positiveRatio = await getPositiveRatio(email);
      negativeRatio = await getNegativeRatio(email);
      categoryMap = await getCategoryMap(email);

      print("categories");
      print(categoryMap);

  ///////////////////////////////////////////////////////////
      var sortedEntries = wordFrequencies.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Get the 50 most common words
      for (int i = 0; i < 50 && i < sortedEntries.length; i++) {
        mostCommonWords[i] = (sortedEntries[i].key);
      }

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
      ////////////////////////////////////

      happyPercent = ((happy / (happy + sad + angry + neutral)) * 100);
      sadPercent = ((sad / (happy + sad + angry + neutral)) * 100);
      angryPercent = ((angry / (happy + sad + angry + neutral)) * 100);
      neutralPercent = ((neutral / (happy + sad + angry + neutral)) * 100);

      dataMap = {
        "% Happy": happyPercent,
        "% Sad": sadPercent,
        "% Angry": angryPercent,
        "% Neutral": neutralPercent,
      };
      ///////////////////////////////////////////////

      List<String> keyList = categoryMap.keys.toList()
        ..sort((k1, k2) => (categoryMap[k2] ?? 0).compareTo(categoryMap[k1] ?? 0))
        ..take(10);

      Set<String> keySet = Set<String>.from(keyList); // Removes duplicates
      keySet = keySet.take(10).toSet(); // Takes first 10 elements

      if (keySet.contains("\n1")) {
        keySet.remove("\n1");
      } else if (keySet.contains("1")) {
        keySet.remove("1");
      }

      topTenKeys = keySet.toList();

      print("toptenkeys");
      print(topTenKeys);

      ////////////////////////////////////////


		} else {
		await supabase.storage
			.from('self-talk-app')
			.uploadBinary('$folderPath/', Uint8List(0));
		print('Folder created');
		}

		backHome();
	  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'User',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              // TextFormField(
              //   controller: _passwordController,
              //   obscureText: true,
              //   decoration: InputDecoration(
              //     labelText: 'Password',
              //   ),
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your password';
              //     }
              //     return null;
              //   },
              // ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Login'),
              ),
              SizedBox(height: 32.0),
              Text(
                waiting_message,
                style: TextStyle(fontSize: 15, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> backHome() async {
   Navigator.push(context, MaterialPageRoute(builder: (context) {
     return const MyHomePage(title: 'Talk to Me Nice');
   }));
  }

  Future<Map<String, num>> getWordFrequencies(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('wordFrequencies')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return {};
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return {};
      } else {
        return Map<String, num>.from(data[0]['wordFrequencies']);
      }
    }
  }

  Future<double> getSad(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('sad')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0.0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0.0;
      } else {
        return data[0]['sad'].toDouble();
      }
    }
  }

  Future<double> getHappy(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('happy')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0.0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0.0;
      } else {
        return data[0]['happy'].toDouble();
      }
    }
  }

  Future<double> getAngry(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('angry')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0.0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0.0;
      } else {
        return data[0]['angry'].toDouble();
      }
    }
  }

  Future<double> getNeutral(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('neutral')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0.0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0.0;
      } else {
        return data[0]['neutral'].toDouble();
      }
    }
  }

  Future<int> getPositiveRatio(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('positiveRatio')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0;
      } else {
        return int.parse(data[0]['positiveRatio'].toString());
      }
    }
  }

  Future<int> getNegativeRatio(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('negativeRatio')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return 0;
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return 0;
      } else {
        return int.parse(data[0]['negativeRatio'].toString());
      }
    }
  }

  Future<Map<String, int>> getCategoryMap(String userId) async {
    final response = await supabase
        .from('between_sessions')
        .select('categoryMap')
        .eq('user', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .execute();
    
    if (response.status != 200) {
      print('Error getting data');
      return {};
    } else {
      final data = response.data;
      if (data.isEmpty) {
        print('No data found for user $userId');
        return {};
      } else {
        return Map<String, int>.from(data[0]['categoryMap']);
      }
    }
  }

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
}