import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';

class APOD {
  final String date;
  final String explanation;
  final String mediaType;
  final String title;
  final String url;

  APOD({
    required this.date,
    required this.explanation,
    required this.mediaType,
    required this.title,
    required this.url,
  });
}

class APODService {
  static Future<APOD> fetchAPODData() async {
    final response = await http.get(Uri.parse('https://api.nasa.gov/planetary/apod?api_key=LCciuJUXeWLHsLSwjtxvr0eQUT2pKYdBTUWizgYL'));
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return APOD(
        date: jsonData['date'],
        explanation: jsonData['explanation'],
        mediaType: jsonData['media_type'],
        title: jsonData['title'],
        url: jsonData['url'],
      );
    } else {
      throw Exception('Failed to fetch APOD data');
    }
  }
}

class TodayPage extends StatefulWidget {
  @override
  TodayState createState() => TodayState();
}

class TodayState extends State<TodayPage> {
  late Future<APOD> apodFuture;
  late Timer? _timer;
  late DateTime _nextMidday;
  late Future<Map<String, dynamic>> _randomTermFuture;
  final _storage = FlutterSecureStorage();
  bool isImageExpanded = false;

  @override
  void initState() {
    super.initState();
    apodFuture = APODService.fetchAPODData();
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
    _randomTermFuture = getRandomTerm();
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

  Future<Uint8List> getThumbnail(String url) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: url,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 200,
      maxWidth: 200,
      quality: 50,
    );
    return thumbnail!;
  }

  @override
  Widget build(BuildContext context) {
    _randomTermFuture = getRandomTerm();
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
                            Text(
                              'Definition',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
                            Text(
                              'Exemple',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
                          borderRadius: BorderRadius.circular(8.0),
                          child: FutureBuilder<APOD>(
                            future: apodFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Failed to fetch APOD data'));
                              } else {
                                final apod = snapshot.data!;
                                print(apod.url);

                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (apod.mediaType == 'image')
                                         GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isImageExpanded = !isImageExpanded;
                                            });

                                            if (isImageExpanded) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ImageFullscreenPage(apod.url,apod.explanation),
                                                ),
                                              );
                                            } else {
                                              Navigator.pop(context);
                                            }
                                          },
                                          child: Hero(
                                            tag: apod.url,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8.0),
                                              child: Stack(
                                                children: [
                                                  Image.network(
                                                    apod.url,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  if (isImageExpanded)
                                                    Container(
                                                      color: Colors.black.withOpacity(0.7),
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            apod.title,
                                                            style: TextStyle(
                                                              fontSize: 20,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (apod.mediaType == 'video')
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: InkWell(
                                            onTap: () {
                                              final urlString = apod.url;
                                              final url = Uri.parse(urlString);
                                              launchVideoUrl(url);
                                            },
                                            child: FutureBuilder<Uint8List>(
                                              future: getThumbnail(apod.url),
                                              builder: (context, snapshot) {
                                                if (snapshot
                                                        .connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                } else if (snapshot
                                                    .hasError) {
                                                  return Center(
                                                    child: Text(
                                                        'Failed to load video thumbnail\nClick to watch the video'),
                                                  );
                                                } else {
                                                  final thumbnailData =
                                                      snapshot.data!;
                                                  return Image.memory(
                                                    thumbnailData,
                                                    fit: BoxFit.cover,
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }
                            },
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
                            'Media of the Day',
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

  void launchVideoUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}


class ImageFullscreenPage extends StatelessWidget {
  final String imageUrl;
  final String explanation;

  ImageFullscreenPage(this.imageUrl, this.explanation);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phototeque'),
      ),
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Colors.black,
          child: PageView.builder(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: MediaQuery.of(context).size.height / 7, // 1/7 of the screen height
                          child: SingleChildScrollView(
                            child: Text(
                              explanation,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
