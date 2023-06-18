import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'dart:async';

class TodayPage extends StatefulWidget {
  @override
  TodayState createState() => TodayState();
}

class TodayState extends State<TodayPage> {
  late Future<Map<String, dynamic>> _randomTermFuture;
  late Timer _timer;
  late Future<APOD> apodFuture;
  late VideoPlayerController _videoPlayerController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.network(
      'https://example.com/video.mp4',
    );
    _initializeVideoPlayerFuture =
        _videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _stopTimer();
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      _randomTermFuture = getRandomTerm();
      _randomTermFuture.then((newTermJson) {
        print(newTermJson);
      });
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

  Future<APOD> fetchAPOD() async {
    final response = await http.get(Uri.parse(
        'https://api.nasa.gov/planetary/apod?api_key=YOUR_API_KEY'));

    if (response.statusCode == 200) {
      return APOD.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch APOD');
    }
  }

  @override
  Widget build(BuildContext context) {
    apodFuture = fetchAPOD();

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
                              mot,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              definition,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              exemple,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.0),
                              topRight: Radius.circular(8.0),
                            ),
                            gradient: LinearGradient(
                              colors: [Colors.indigo.shade300, Colors.indigo],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0, 0.5],
                            ),
                          ),
                          padding: EdgeInsets.all(16),
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
                  SizedBox(height: 16),
                  FutureBuilder<APOD>(
                    future: apodFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Failed to fetch APOD data'));
                      } else {
                        final apod = snapshot.data!;
                        return Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.4,
                              margin: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Stack(
                                    children: [
                                      if (apod.mediaType == 'image')
                                        Image.network(
                                          apod.url,
                                          fit: BoxFit.cover,
                                        ),
                                      if (apod.mediaType == 'video')
                                        FutureBuilder<void>(
                                          future: _initializeVideoPlayerFuture,
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              return VideoPlayer(
                                                  _videoPlayerController);
                                            } else {
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                          },
                                        ),
                                      if (apod.mediaType == 'video')
                                        InkWell(
                                          onTap: () {
                                            final urlString = apod.url;
                                            final url = Uri.parse(urlString);
                                            launchVideoUrl(url);
                                          },
                                          child: Icon(
                                            Icons.play_arrow,
                                            size: 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                    ],
                                  ),
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
                        );
                      }
                    },
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

class APOD {
  final String mediaType;
  final String url;

  APOD({required this.mediaType, required this.url});

  factory APOD.fromJson(Map<String, dynamic> json) {
    return APOD(
      mediaType: json['media_type'],
      url: json['url'],
    );
  }
}
