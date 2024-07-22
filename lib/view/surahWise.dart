import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'surahDetail.dart';

class SurahWisePage extends StatefulWidget {
  @override
  State<SurahWisePage> createState() => _SurahWisePageState();
}

class _SurahWisePageState extends State<SurahWisePage> {
  List<dynamic>? surahs;

  @override
  void initState() {
    super.initState();
    getSurahs();
  }

  Future<void> getSurahs() async {
    const url = "https://api.alquran.cloud/v1/surah";
    SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('surahs', json.encode(data['data']));
        setState(() {
          surahs = data['data'];
        });
      } else {
        throw Exception('Failed to load surahs');
      }
    } catch (e) {
      final storedData = prefs.getString('surahs');
      if (storedData != null) {
        setState(() {
          surahs = json.decode(storedData);
        });
      } else {
        throw Exception('No data available offline');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Surah-wise',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 208, 204, 204)),
          ),
          surahs == null
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: surahs!.length,
                  itemBuilder: (context, index) {
                    var surah = surahs![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetail(surah: surah),
                            ),
                          );
                        },
                        title: Text(
                          surah['englishName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          surah['name'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
