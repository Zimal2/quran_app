import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;
import 'package:audioplayers/audioplayers.dart';

class Chapterwisedetail extends StatefulWidget {
  final int index;

  Chapterwisedetail({super.key, required this.index});

  @override
  State<Chapterwisedetail> createState() => _ChapterwisedetailState();
}

class _ChapterwisedetailState extends State<Chapterwisedetail> {
  List<dynamic>? ayahs;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int? currentAyahIndex;

  @override
  void initState() {
    super.initState();
    loadAyahs();
    audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        isPlaying = false;
        currentAyahIndex = null;
      });
    });
  }

  Future<void> getChapters() async {
    final url = "https://api.alquran.cloud/v1/juz/${widget.index}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final ayahsData = data['data']['ayahs'];
        setState(() {
          ayahs = ayahsData;
        });
        saveAyahsToSharedPreferences(ayahsData);
      } else {
        throw Exception('Failed to load ayahs');
      }
    } catch (e) {
      throw Exception('Failed to load ayahs');
    }
  }

  Future<void> saveAyahsToSharedPreferences(List<dynamic> ayahsData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ayahs_${widget.index}', json.encode(ayahsData));
  }

  Future<void> loadAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAyahs = prefs.getString('ayahs_${widget.index}');
    print("stored ayahs:$storedAyahs")
;    if (storedAyahs != null) {
      setState(() {
        ayahs = json.decode(storedAyahs);
      });
    } else {
      await getChapters();
    }
  }

  void playAyah(String audioUrl, int index) async {
    if (isPlaying && currentAyahIndex == index) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
      });
    } else {
      await audioPlayer.play(UrlSource(audioUrl));
      setState(() {
        isPlaying = true;
        currentAyahIndex = index;
      });
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chapter ${widget.index}',
          style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration:const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ayahs == null
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: ayahs!.length,
                itemBuilder: (context, index) {
                  var ayah = ayahs![index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        ayah['text'],
                        style: TextStyle(fontSize: 18, fontFamily: 'Roboto'),
                      ),
                      subtitle: Text(
                        'Ayah ${ayah['number']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isPlaying && currentAyahIndex == index
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_fill,
                          size: 29,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          String audioUrl =
                              quran.getAudioURLByVerseNumber(ayah['number']);
                          playAyah(audioUrl, index);
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
