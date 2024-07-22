import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';

class SurahDetail extends StatefulWidget {
  final dynamic surah;

  const SurahDetail({super.key, required this.surah});

  @override
  State<SurahDetail> createState() => _SurahDetailState();
}

class _SurahDetailState extends State<SurahDetail> {
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

  Future<void> getAyahsFromApi() async {
    final url = "https://api.alquran.cloud/v1/surah/${widget.surah['number']}";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ayahs = data['data']['ayahs'];
        });
        saveAyahsToSharedPreferences(ayahs!);
      } else {
        throw Exception('Failed to load ayahs');
      }
    } catch (e) {
      throw Exception('Failed to load ayahs');
    }
  }

  Future<void> saveAyahsToSharedPreferences(List<dynamic> ayahsData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'ayahs_${widget.surah['number']}', json.encode(ayahsData));
  }

  Future<void> loadAyahs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedAyahs = prefs.getString('ayahs_${widget.surah['number']}');
    print("stored ayahs:$storedAyahs");
    if (storedAyahs != null) {
      setState(() {
        ayahs = json.decode(storedAyahs);
      });
    } else {
      await getAyahsFromApi();
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
        title: Text('Surah: ${widget.surah['englishName']}'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          ayahs == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Revelation Type: ${widget.surah['revelationType']}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Number of Ayahs: ${widget.surah['numberOfAyahs']}',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      flex: 5,
                      child: ListView.builder(
                        itemCount: ayahs!.length,
                        itemBuilder: (context, index) {
                          var ayah = ayahs![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  ayah['text'],
                                  style: const TextStyle(
                                    fontFamily: 'CustomFont',
                                  ),
                                ),
                                subtitle: Text(
                                  'Ayah ${ayah['numberInSurah']}',
                                  style: const TextStyle(
                                    fontFamily: 'CustomFont',
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    isPlaying && currentAyahIndex == index
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    color: Colors.teal,
                                  ),
                                  onPressed: () {
                                    String audioUrl = quran.getAudioURLByVerse(
                                        widget.surah['number'], index + 1);
                                    playAyah(audioUrl, index);
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
