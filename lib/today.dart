import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class TodayPage extends StatefulWidget {
  @override
  TodayState createState() => TodayState();
}

class TodayState extends State<TodayPage> {
 late Timer? _timer;
  late DateTime _nextMidday;
  late Future<Map<String, dynamic>> _randomTermFuture;
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _calculateNextMidday();
    _loadStoredTerm();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _calculateNextMidday() {
    DateTime now = DateTime.now();
    _nextMidday = DateTime(now.year, now.month, now.day, 12, 0);
    if (now.isAfter(_nextMidday)) {
      _nextMidday = _nextMidday.add(Duration(days: 1));
    }
  }

  void _loadStoredTerm() async {
    String? storedTerm = await _storage.read(key: 'term_of_the_day');
    if (storedTerm != null) {
      setState(() {
        _randomTermFuture = Future.value(jsonDecode(storedTerm));
      });
    }
    print(storedTerm);
  }

  void _startTimer() async {

    _randomTermFuture=getRandomTerm();
    DateTime now = DateTime.now();
    if (now.isBefore(_nextMidday)) {
      String? storedTerm = await _storage.read(key: 'term_of_the_day');
      if (storedTerm != null) {
        setState(() {
          _randomTermFuture = Future.value(jsonDecode(storedTerm));
          print('yes');
        });
      }
    }

    Duration durationUntilMidday = _nextMidday.difference(now);
    _timer = Timer(durationUntilMidday, () async {
      setState(() {
        _randomTermFuture = getRandomTerm();
        _calculateNextMidday();
        _startTimer();
      });

      Map<String, dynamic> newTerm = await _randomTermFuture;
      print(newTerm);
      String newTermJson = jsonEncode(newTerm);
      await _storage.write(key: 'term_of_the_day', value: newTermJson);
      print(newTermJson);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<Map<String, dynamic>> getRandomTerm() async {
    String jsonString = await rootBundle.loadString('assets/lexique.json');
    var jsonData = jsonDecode(jsonString);
    List<dynamic> terms = jsonData['terms'];

    int randomIndex = Random().nextInt(terms.length);

    return terms[randomIndex];
  }



  @override
  Widget build(BuildContext context) {
    _randomTermFuture=getRandomTerm();
   _randomTermFuture.then((value) {
      print(value);
    });

    _startTimer();
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _randomTermFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            String mot = snapshot.data!['mot'];
            String definition = snapshot.data!['definition'];
            String exemple = snapshot.data!['exemple'];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.3,
                        margin: EdgeInsets.all(16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.indigo.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              '$mot',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text('Definition', style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                            Text(
                              '$definition',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            SizedBox(height: 8),
                            Text('Exemple', style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold
                            ),
                            ),
                            Text(
                              '$exemple',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 5,
                        left: MediaQuery.of(context).size.width * 0.1 - 24,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          child: Text(
                            'Word of the Day',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.height * 0.4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/nebuleuse_galaxie/nebuleuse_de_laigle.jpeg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.black.withOpacity(0.7),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            'Picture of the Day',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}