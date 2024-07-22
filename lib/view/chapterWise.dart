import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quran_app/view/chapterWiseDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChapterWisePage extends StatefulWidget {
  @override
  State<ChapterWisePage> createState() => _ChapterWisePageState();
}

class _ChapterWisePageState extends State<ChapterWisePage> {
  final List<Map<String, String>> paras = [
    {'number': '1', 'name': 'الم'},
    {'number': '2', 'name': 'سَيَقُولُ'},
    {'number': '3', 'name': 'تِلْكَ الرُّسُلُ'},
    {'number': '4', 'name': 'لَنْ تَنَالُوا'},
    {'number': '5', 'name': 'وَالْمُحْصَنَاتُ'},
    {'number': '6', 'name': 'يَا أَيُّهَا'},
    {'number': '7', 'name': 'وَإِذَا سَمِعُوا'},
    {'number': '8', 'name': 'وَلَوْ أَنَّنَا'},
    {'number': '9', 'name': 'قَدْ أَفْلَحَ'},
    {'number': '10', 'name': 'وَاعْلَمُوا'},
    {'number': '11', 'name': 'يَعْتَذِرُونَ'},
    {'number': '12', 'name': 'وَمَا مِنْ دَابَّةٍ'},
    {'number': '13', 'name': 'وَمَا أُبَرِّئُ'},
    {'number': '14', 'name': 'رُبَمَا'},
    {'number': '15', 'name': 'سُبْحَانَ الَّذِي'},
    {'number': '16', 'name': 'قَالَ أَلَمْ'},
    {'number': '17', 'name': 'اقْتَرَبَ'},
    {'number': '18', 'name': 'قَدْ أَفْلَحَ'},
    {'number': '19', 'name': 'وَقَالَ الَّذِينَ'},
    {'number': '20', 'name': 'أَمَّنْ خَلَقَ'},
    {'number': '21', 'name': 'اتْلُ مَا أُوحِيَ'},
    {'number': '22', 'name': 'وَمَنْ يَقْنُتْ'},
    {'number': '23', 'name': 'وَمَا لِي'},
    {'number': '24', 'name': 'فَمَنْ أَظْلَمُ'},
    {'number': '25', 'name': 'إِلَيْهِ يُرَدُّ'},
    {'number': '26', 'name': 'حم'},
    {'number': '27', 'name': 'قَالَ فَمَا خَطْبُكُمْ'},
    {'number': '28', 'name': 'قَدْ أَفْلَحَ'},
    {'number': '29', 'name': 'تَبَارَكَ الَّذِي'},
    {'number': '30', 'name': 'عَمَّ يَتَسَاءَلُونَ'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran Paras'),
        backgroundColor: Color.fromARGB(255, 0, 123, 255),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 200, 230, 255)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView.builder(
          itemCount: paras.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chapterwisedetail(index: index + 1),
                    ),
                  );
                },
                leading: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 150, 179, 227),
                  child: Text(paras[index]['number']!),
                ),
                title: Text(
                  paras[index]['name']!,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
